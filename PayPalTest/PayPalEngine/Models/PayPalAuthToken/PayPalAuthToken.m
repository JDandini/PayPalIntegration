//
//  PayPalAuthToken.m
//  PayPalTest
//
//  Created by Javier on 4/17/19.
//  Copyright © 2019 GAIA Design. All rights reserved.
//

#import "PayPalAuthToken.h"

@implementation PayPalAuthToken
@synthesize expirationTime;
@synthesize appId;
@synthesize token;

- (instancetype)initWithJSON: (NSDictionary *) json {
    self = [super init];
    if (self) {
        NSString *expiresString = [json valueForKey:@"expires_in"];
        expirationTime = (expiresString != nil) ? expiresString.doubleValue : 0;
        appId = [json valueForKey:@"app_id"];
        token = [json valueForKey:@"access_token"];
    }
    return self;
}
@end
