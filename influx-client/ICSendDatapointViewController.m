//
//  ICSendDatapointViewController.m
//  influx-client
//
//  Created by Courtf on 12/17/13.
//  Copyright (c) 2013 ESRI. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import "ICSendDatapointViewController.h"
#import "ICInfluxDbClient.h"
#import <xlocale.h>

@interface ICSendDatapointViewController ()
@property (weak, nonatomic) IBOutlet UITextField *seriesField;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UITextField *typeField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@end

@implementation ICSendDatapointViewController {
    MBProgressHUD *HUD;
    ICInfluxDbClient *client;
}

// InfluxDB Settings
// (TODO: make these app preferences? that would still leave columns as un-modifiable during runtime...)
static NSString* const INFLUX_HOST = @"";
static int const INFLUX_PORT = 1234;
static NSString* const INFLUX_USER = @"";
static NSString* const INFLUX_PASS = @"";
static NSString* const INFLUX_DB_NAME = @"";

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

    self.seriesField.delegate = self;
    self.typeField.delegate = self;
    self.valueField.delegate = self;

    client = [[ICInfluxDbClient alloc] initWithHost:INFLUX_HOST port:INFLUX_PORT user:INFLUX_USER pass:INFLUX_PASS dbName:INFLUX_DB_NAME];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark IBActions

- (IBAction)sendWasTapped:(id)sender {
    if (sender != self.sendButton) return;

    // The hud will disable all input on the view (use the highest view possible in the view hierarchy)
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;

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

        // write point!
        [client writePoints:@[point]
                   toSeries:self.seriesField.text
                withColumns:[self getColumnsArray]
                  onSuccess:^(NSMutableData *response) {
                      NSLog(@"On Success block fired with data: %@", [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding]);
                      [self toastMessage:NSLocalizedString(@"successfulPostToast", @"Short message to indicate that the data was sent succesfully.")];
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
    HUD.mode = MBProgressHUDModeText;
    HUD.labelText = message;
    HUD.margin = 10.f;
    HUD.yOffset = 150.f;
    [HUD hide:YES afterDelay:2];
}

- (NSArray*)getColumnsArray
{
    return @[ @"timestamp", @"type", @"value" ];
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidden
    [hud removeFromSuperview];
    hud = nil;
}

@end
