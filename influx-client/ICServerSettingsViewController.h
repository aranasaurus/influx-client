//
//  ICServerSettingsViewController.h
//  influx-client
//
//  Created by Ryan Arana on 12/28/13.
//  Copyright (c) 2013 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ICServerSettingsViewController;

@protocol ICServerSettingsViewControllerDelegate <NSObject>
- (void)settingsViewControllerDidFinish:(ICServerSettingsViewController *)controller;
@end

@interface ICServerSettingsViewController : UIViewController

@property (weak, nonatomic) id<ICServerSettingsViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *hostTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (weak, nonatomic) IBOutlet UITextField *dbNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)done:(id)sender;

@end
