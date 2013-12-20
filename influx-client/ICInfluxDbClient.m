//
//  ICInfluxDbClient.m
//  influx-client
//
//  Created by Courtf on 12/18/13.
//  Copyright (c) 2013 ESRI. All rights reserved.
//

#import "ICInfluxDbClient.h"
#import "ICURLConnectionDelegate.h"

@implementation ICInfluxDbClient {
    NSString *host;
    int port;
    NSString *user;
    NSString *pass;
    NSString *dbName;
}

- (id)initWithHost:(NSString *)aHost port:(int)aPort user:(NSString *)aUser pass:(NSString *)aPass dbName:(NSString *)aDbName {
    if (self = [super init]) {
        host = aHost;
        port = aPort;
        user = aUser;
        pass = aPass;
        dbName = aDbName;

        return self;
    } else {
        return nil;
    }
}

- (void) writePoints:(NSArray *)points toSeries:(NSString *)seriesName withColumns:(NSArray *)columns onSuccess:(void (^)(NSMutableData *response))success onFailure:(void (^)(NSError *error))failure
{
    // prepare JSON array
    NSMutableArray *mutablePayload = [NSMutableArray new];
    NSMutableDictionary *seriesObject = [NSMutableDictionary new];

    seriesObject[@"name"] = seriesName;
    seriesObject[@"columns"] = columns;
    seriesObject[@"points"] = points;

    [mutablePayload addObject:seriesObject];

    NSArray *payload = [NSArray arrayWithArray:mutablePayload];
    NSError *anError;

    // convert array to json data
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&anError];

    if (!jsonData && anError) {
        failure(anError);
        return;
    }

    // get url, and set up the request object
    NSURL *url = [NSURL URLWithString:[self getUrl:@"series"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL]];

    // set request method, content type header, and add json data to body
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];

    // initialize a connection from request, and start it
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:[[ICURLConnectionDelegate alloc] initWithSuccessBlock:success andFailureBlock:failure]];
    [connection start];
}

- (NSString *)getUrl:(NSString *)action
{
    return [NSString stringWithFormat:@"http://%@:%d/db/%@/%@?u=%@&p=%@", host, port, dbName, action, user, pass];
}

@end
