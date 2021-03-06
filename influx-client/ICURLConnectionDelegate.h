//
//  ICURLConnectionDelegate.h
//  influx-client
//
//  Created by Courtf on 12/19/13.
//  Copyright (c) 2013 ESRI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICURLConnectionDelegate : NSObject <NSURLConnectionDataDelegate>
- (id)init __attribute__((unavailable("init is unavailable, use initWithSuccessBlock:andFailureBlock:")));
- (id)initWithSuccessBlock:(void (^)(NSData *response))success andFailureBlock:(void (^)(NSError *error))failure;
@end
