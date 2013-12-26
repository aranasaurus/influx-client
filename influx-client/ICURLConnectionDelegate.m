//
//  ICURLConnectionDelegate.m
//  influx-client
//
//  Created by Courtf on 12/19/13.
//  Copyright (c) 2013 ESRI. All rights reserved.
//

#import "ICURLConnectionDelegate.h"

@interface ICURLConnectionDelegate ()
@property (strong, nonatomic) NSMutableData *receivedData;
@property (strong, nonatomic) void (^success)(NSMutableData *response);
@property (strong, nonatomic) void (^failure)(NSError *error);
@end

@implementation ICURLConnectionDelegate

- (id)initWithSuccessBlock:(void (^)(NSData *response))onSuccess andFailureBlock:(void (^)(NSError *error))onFailure
{
    if (self = [super init]) {
        self.success = onSuccess;
        self.failure = onFailure;
        self.receivedData = [NSMutableData new];
        return self;
    } else {
        return nil;
    }
}

// this method might be calling more than one times according to incoming data size
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
}

// if there is an error occured, this method will be called by connection
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    self.failure(error);
}

// if data is successfully received, this method will be called by connection
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.success([NSData dataWithData:self.receivedData]);
}
@end
