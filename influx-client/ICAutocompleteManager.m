//
//  ICAutocompleteManager.m
//  influx-client
//
//  Created by Ryan Arana on 1/4/14.
//  Copyright (c) 2014 ESRI. All rights reserved.
//

#import "ICAutocompleteManager.h"

static ICAutocompleteManager *sharedManager;

@implementation ICAutocompleteManager

+ (ICAutocompleteManager *)sharedManager {
    static dispatch_once_t done;
    dispatch_once(&done, ^{
        sharedManager = [[ICAutocompleteManager alloc] init];
    });
    return sharedManager;
}

#pragma mark - ICAutocompleteTextFieldDelegate

- (NSString *)textField:(HTAutocompleteTextField *)textField
    completionForPrefix:(NSString *)prefix
             ignoreCase:(BOOL)ignoreCase {
    NSDictionary *autocompleteDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:IC_AUTOCOMPLETE_KEY];
    if (!autocompleteDictionary) {
        autocompleteDictionary = [NSDictionary dictionary];
    }

    NSArray *autocompleteArray;
    if (textField.accessibilityLabel) {
        autocompleteArray = autocompleteDictionary[textField.accessibilityLabel];
    }

    NSString *stringToLookFor = [textField.text lowercaseString];
    for (NSString *stringFromReference in autocompleteArray) {
        NSString *stringToCompare = [stringFromReference lowercaseString];

        if ([stringToCompare hasPrefix:stringToLookFor]) {
            return [stringFromReference stringByReplacingCharactersInRange:[stringToCompare rangeOfString:stringToLookFor] withString:@""];
        }
    }

    return @"";
}

@end
