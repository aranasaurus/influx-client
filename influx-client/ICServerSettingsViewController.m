//
//  ICServerSettingsViewController.m
//  influx-client
//
//  Created by Ryan Arana on 12/28/13.
//  Copyright (c) 2013 ESRI. All rights reserved.
//

#import "ICServerSettingsViewController.h"

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender {
    [self.delegate settingsViewControllerDidFinish:self];
}

@end
