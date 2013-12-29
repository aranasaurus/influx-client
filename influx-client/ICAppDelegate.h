//
//  ICAppDelegate.h
//  influx-client
//
//  Created by Courtf on 12/16/13.
//  Copyright (c) 2013 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ICInfluxDbClient;

@interface ICAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ICInfluxDbClient *dbClient;

- (void)loadClientFromDefaults;
@end
