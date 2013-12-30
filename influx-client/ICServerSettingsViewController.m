//
//  ICServerSettingsViewController.m
//  influx-client
//
//  Created by Ryan Arana on 12/28/13.
//  Copyright (c) 2013 ESRI. All rights reserved.
//

#import "ICServerSettingsViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "ICAppDelegate.h"

@interface ICServerSettingsViewController ()

@end

@implementation ICServerSettingsViewController

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
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.hostTextField.text = [defaults objectForKey:IC_HOST_KEY];
    self.portTextField.text = [[defaults objectForKey:IC_PORT_KEY] stringValue];
    self.dbNameTextField.text = [defaults objectForKey:IC_DBNAME_KEY];
    self.usernameTextField.text = [defaults objectForKey:IC_USER_KEY];
    self.passwordTextField.text = [defaults objectForKey:IC_PASS_KEY];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *hostURL = [NSURL URLWithString:self.hostTextField.text];
    if (!hostURL) {
        [self toastMessage:@"Please enter a valid host URL."];
        return;
    } else {
        [defaults setObject:hostURL.absoluteString forKey:IC_HOST_KEY];
    }

    NSNumberFormatter *formatter = [NSNumberFormatter new];
    NSNumber *port = [formatter numberFromString:self.portTextField.text];
    if (!port) {
        [self toastMessage:@"Please enter a valid port number."];
        return;
    } else {
        [defaults setObject:port forKey:IC_PORT_KEY];
    }

    if (!self.dbNameTextField.text) {
        [self toastMessage:@"Please enter a database name."];
        return;
    } else {
        [defaults setObject:self.dbNameTextField.text forKey:IC_DBNAME_KEY];
    }

    if (!self.usernameTextField.text) {
        [self toastMessage:@"Please enter a username."];
        return;
    } else {
        [defaults setObject:self.usernameTextField.text forKey:IC_USER_KEY];
    }

    if (!self.passwordTextField.text) {
        [self toastMessage:@"Please enter a password."];
        return;
    } else {
        [defaults setObject:self.passwordTextField.text forKey:IC_PASS_KEY];
    }

    [defaults synchronize];
    [((ICAppDelegate *)[UIApplication sharedApplication].delegate) loadClientFromDefaults];
    [self.delegate settingsViewControllerDidFinish:self];
}

- (void)toastMessage:(NSString *)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    [hud hide:YES afterDelay:2];
}
@end
