//
//  ICInfluxDbClient.m
//  influx-client
//
//  Created by Courtf on 12/18/13.
//  Copyright (c) 2013 ESRI. All rights reserved.
//

#import "ICInfluxDbClient.h"
#import "ICURLConnectionDelegate.h"

@interface ICInfluxDbClient ()
@property (copy, nonatomic) NSString *host;
@property (assign, nonatomic) int port;
@property (copy, nonatomic) NSString *user;
@property (copy, nonatomic) NSString *pass;
@property (copy, nonatomic) NSString *dbName;
@end

@implementation ICInfluxDbClient

- (id)initWithHost:(NSString *)aHost port:(int)aPort user:(NSString *)aUser pass:(NSString *)aPass dbName:(NSString *)aDbName {
    if (self = [super init]) {
        self.host = aHost;
        self.port = aPort;
        self.user = aUser;
        self.pass = aPass;
        self.dbName = aDbName;

        return self;
    } else {
        return nil;
    }
}

- (void) writePoints:(NSArray *)points toSeries:(NSString *)seriesName withColumns:(NSArray *)columns onSuccess:(void (^)(NSData *response))success onFailure:(void (^)(NSError *error))failure
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
    return [NSString stringWithFormat:@"http://%@:%d/db/%@/%@?u=%@&p=%@", self.host, self.port, self.dbName, action, self.user, self.pass];
}

@end
