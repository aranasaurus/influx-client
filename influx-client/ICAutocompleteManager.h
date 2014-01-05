//
//  ICAutocompleteManager.h
//  influx-client
//
//  Created by Ryan Arana on 1/4/14.
//  Copyright (c) 2014 ESRI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTAutocompleteTextField.h"

@interface ICAutocompleteManager : NSObject <HTAutocompleteDataSource>

+ (ICAutocompleteManager *)sharedManager;

@end
