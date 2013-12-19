//
//  ICURLConnectionDelegate.m
//  influx-client
//
//  Created by Courtf on 12/19/13.
//  Copyright (c) 2013 ESRI. All rights reserved.
//

#import "ICURLConnectionDelegate.h"

@implementation ICURLConnectionDelegate {
    NSMutableData *receivedData;
    void (^success)(NSMutableData *response);
    void (^failure)(NSError *error);
}

- (id)initWithSuccessBlock:(void (^)(NSMutableData *response))onSuccess andFailureBlock:(void (^)(NSError *error))onFailure
{
    if (self = [super init]) {
        success = onSuccess;
        failure = onFailure;
        receivedData = [NSMutableData new];
        return self;
    } else {
        return nil;
    }
}

// this method might be calling more than one times according to incoming data size
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

// if there is an error occured, this method will be called by connection
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    failure(error);
}

// if data is successfully received, this method will be called by connection
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    success(receivedData);
}
@end
