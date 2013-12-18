//
//  ICSendDatapointViewController.m
//  influx-client
//
//  Created by Courtf on 12/17/13.
//  Copyright (c) 2013 ESRI. All rights reserved.
//

#import "ICSendDatapointViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface ICSendDatapointViewController ()
@property (weak, nonatomic) IBOutlet UITextField *seriesField;
@property (weak, nonatomic) IBOutlet UITextField *keyField;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@end

@implementation ICSendDatapointViewController {
    MBProgressHUD *HUD;
}

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
    self.keyField.delegate = self;
    self.valueField.delegate = self;

    // TODO: create InfluxDBClient object here
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

    // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];

    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;

    // Show the HUD while the provided method executes in a new thread
    [HUD showWhileExecuting:@selector(validateAndSend) onTarget:self withObject:nil animated:YES];
}

#pragma mark -
#pragma mark Execution code

- (void)validateAndSend
{
    if (self.seriesField.text.length > 0 && self.keyField.text.length > 0 && self.valueField.text.length > 0) {
        // TODO: tell InfluxDbClient to send the data
        sleep(2);
    } else {
        HUD.mode = MBProgressHUDModeText;
        HUD.labelText = @"Enter all 3 fields!";
        HUD.margin = 10.f;
        HUD.yOffset = 150.f;
        sleep(2);
    }
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
