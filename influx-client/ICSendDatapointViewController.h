//
//  ICSendDatapointViewController.h
//  influx-client
//
//  Created by Courtf on 12/17/13.
//  Copyright (c) 2013 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "ICServerSettingsViewController.h"

@interface ICSendDatapointViewController : UIViewController <MBProgressHUDDelegate, UITextFieldDelegate, ICServerSettingsViewControllerDelegate>

@end
