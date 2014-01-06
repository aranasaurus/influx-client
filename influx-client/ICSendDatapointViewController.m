//
//  ICSendDatapointViewController.m
//  influx-client
//
//  Created by Courtf on 12/17/13.
//  Copyright (c) 2013 ESRI. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import "ICSendDatapointViewController.h"
#import "ICAppDelegate.h"
#import "ICAutocompleteManager.h"
#import <xlocale.h>
#import <HTAutocompleteTextField/HTAutocompleteTextField.h>

@interface ICSendDatapointViewController () {
    float _hudOffset;
}
@property (weak, nonatomic) IBOutlet HTAutocompleteTextField *seriesField;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet HTAutocompleteTextField *typeField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (weak, nonatomic) IBOutlet UITableView *recentItemsTableView;
@property (strong, nonatomic, readonly) NSArray *recentItems;
@end

@implementation ICSendDatapointViewController

// used for NSDate -> NSString formatting
static char const* formatString = "%FT%T%z";
static locale_t const locale = (locale_t)NULL;

#pragma mark -
#pragma mark Lifecycle methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [HTAutocompleteTextField setDefaultAutocompleteDataSource:[ICAutocompleteManager sharedManager]];

    self.seriesField.delegate = self;
    self.seriesField.text = [[NSUserDefaults standardUserDefaults] objectForKey:IC_SERIES_KEY];
    self.typeField.delegate = self;
    self.valueField.delegate = self;

    [self keyboardDismissed];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAppeared) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDismissed) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDismissed {
    _hudOffset = 150.0f;
}

- (void)keyboardAppeared {
    _hudOffset = 0.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark IBActions

- (IBAction)clearAutocompleteCache:(id)sender {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:IC_AUTOCOMPLETE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self toastMessage:@"Cleared!"];
}

- (IBAction)clearRecentItems:(id)sender {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:IC_RECENT_ITEMS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self toastMessage:@"Cleared!"];
    [self.recentItemsTableView reloadData];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSDictionary *completesDict = [[NSUserDefaults standardUserDefaults] objectForKey:IC_AUTOCOMPLETE_KEY];
    if (!completesDict) {
        completesDict = [NSDictionary dictionary];
    }

    NSArray *completesArray = completesDict[textField.accessibilityLabel];
    if (!completesArray) {
        completesArray = [NSArray array];
    }

    NSMutableSet *mutableCompletes = [NSMutableSet setWithArray:completesArray];
    [mutableCompletes addObject:textField.text];

    NSMutableDictionary *mutableDictionary = [completesDict mutableCopy];
    mutableDictionary[textField.accessibilityLabel] = [mutableCompletes allObjects];
    [[NSUserDefaults standardUserDefaults] setObject:mutableDictionary forKey:IC_AUTOCOMPLETE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)sendWasTapped:(id)sender {
    if (sender != self.sendButton) return;

    // The hud will disable all input on the view (use the highest view possible in the view hierarchy)
    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.HUD.userInteractionEnabled = NO;

    // Regiser for HUD callbacks so we can remove it from the window at the right time
    self.HUD.delegate = self;

    [self validateAndSend];
}

#pragma mark -
#pragma mark Execution code

- (void)validateAndSend
{
    if (self.seriesField.text.length > 0 && self.typeField.text.length > 0 && self.valueField.text.length > 0) {
        NSMutableArray *point = [NSMutableArray new];
        // add fields in the order shown in [self getColumnsArray]
        [point addObject:[self iso8601DateStringFromDate:[NSDate date]]];
        [point addObject:self.typeField.text];
        NSNumber *numericVal = [self numericFromString:self.typeField.text];

        if (numericVal) {
            [point addObject:numericVal];
        } else {
            [point addObject:self.valueField.text];
        }

        [[NSUserDefaults standardUserDefaults] setObject:self.seriesField.text forKey:IC_SERIES_KEY];

        // write point!
        NSArray *columns = @[ @"timestamp", @"type", @"value" ];
        NSString *series = self.seriesField.text;
        ICAppDelegate *appDelegate = (ICAppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.dbClient writePoints:@[point]
                                 toSeries:series
                              withColumns:columns
                                onSuccess:^(NSData *response) {
                                    NSLog(@"On Success block fired with data: %@", [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding]);
                                    [self toastMessage:NSLocalizedString(@"successfulPostToast", @"Short message to indicate that the data was sent succesfully.")];
                                    NSMutableArray *mutableRecents = [self.recentItems mutableCopy];
                                    if (!mutableRecents) {
                                        mutableRecents = [NSMutableArray array];
                                    }
                                    NSMutableDictionary *mutablePoint = [NSMutableDictionary dictionaryWithObjects:point forKeys:columns];
                                    mutablePoint[@"series"] = series;
                                    [mutableRecents insertObject:[mutablePoint copy] atIndex:0];
                                    [[NSUserDefaults standardUserDefaults] setObject:[mutableRecents copy] forKey:IC_RECENT_ITEMS_KEY];
                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                    [self.recentItemsTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                                }
                                onFailure:^(NSError *error) {
                                    NSLog(@"On Failure block fired with error: %@", error);
                                    [self toastMessage:NSLocalizedString(@"failedPostToast", @"Short message to indicate that there was an error which can be seen in the logs.")];
                                }
        ];
    } else {
        [self toastMessage:NSLocalizedString(@"missingFieldToast", @"Let the user know, in as few words as possible, that they must enter something into all three fields.")];
    }
}

- (void)toastMessage:(NSString *)message
{
    self.HUD.mode = MBProgressHUDModeText;
    self.HUD.labelText = message;
    self.HUD.margin = 10.f;
    self.HUD.yOffset = _hudOffset;
    [self.HUD hide:YES afterDelay:2];
}

- (NSString *)iso8601DateStringFromDate:(NSDate *)date {
    char buf[256];
    struct tm *local;
    time_t t = (time_t)[date timeIntervalSince1970];

    // get the raw time
    time(&t);
    // convert it to local time as a struct
    local = localtime(&t);

    strftime_l(buf, 255, formatString, local, locale);
    return [NSString stringWithFormat:@"%s", buf];
}

- (NSNumber *)numericFromString:(NSString *)str {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *number = [formatter numberFromString:str];
    return number; // If the string is not numeric, number will be nil
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [self.HUD hide:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidden
    [hud removeFromSuperview];
}

#pragma mark -
#pragma mark ICServerSettingsViewControllerDelegate (and related) methods

- (void)settingsViewControllerDidFinish:(ICServerSettingsViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"flip"]) {
        [[segue destinationViewController] setDelegate:self];
    }
}

#pragma mark -
#pragma mark UITableView Stuff
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.recentItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"logCell" forIndexPath:indexPath];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *valueLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *seriesLabel = (UILabel *)[cell viewWithTag:3];

    NSDictionary *item = self.recentItems[(NSUInteger)indexPath.row];
    NSString *dateString = [item[@"timestamp"] stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    dateString = [dateString stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    dateString = [dateString stringByReplacingCharactersInRange:NSMakeRange(dateString.length-5, 5) withString:@""];
    dateLabel.text = dateString;

    valueLabel.text = [NSString stringWithFormat:@"%@: %@", item[@"type"], item[@"value"]];
    seriesLabel.text = item[@"series"];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 53;
}

- (NSArray *)recentItems {
    return [[NSUserDefaults standardUserDefaults] objectForKey:IC_RECENT_ITEMS_KEY];
}

@end
