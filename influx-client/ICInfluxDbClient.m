//
//  ICInfluxDbClient.m
//  influx-client
//
//  Created by Courtf on 12/18/13.
//  Copyright (c) 2013 ESRI. All rights reserved.
//

#import "ICInfluxDbClient.h"

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

- (NSString *)getUrl:(NSString *)action
{
    return [NSString stringWithFormat:@"http://%@:%d/db/%@/%@?u=%@&p=%@", host, port, dbName, action, user, pass];
}

@end
