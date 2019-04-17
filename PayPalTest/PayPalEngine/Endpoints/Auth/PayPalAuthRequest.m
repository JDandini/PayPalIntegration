//
//  PayPalAuthRequest.m
//  PayPalTest
//
//  Created by Javier on 4/17/19.
//  Copyright © 2019 GAIA Design. All rights reserved.
//

#import "PayPalAuthRequest.h"
#import "RESTMethod.h"
#import "NSString+Base64.h"

@implementation PayPalAuthRequest
@synthesize baseURL;
@synthesize method;
@synthesize path;
@synthesize timeout;
@synthesize parameters;
@synthesize headers;

- (instancetype)init {
    self = [super init];
    if (self) {
        #if DEBUG
        NSString *clientID = @"";
        NSString *secret = @"";
        #else
        NSString *clientID = @"";
        NSString *secret = @"";
        #endif
        NSString *key = [NSString stringWithFormat:@"%@:%@", clientID, secret];
        key = [NSString encodeBase64String:key];
        path = @"/v1/oauth2/token";
        NSString *urlString = [NSString stringWithFormat:@"%@%@", kPayPalBase, path];
        baseURL = [NSURL URLWithString:urlString];
        method = HTTPMethodPOST;
        timeout = 15;
        headers = @{@"Content-Type": @"application/x-www-form-urlencoded",
                    @"Authorization": [NSString stringWithFormat:@"Basic %@",key]
                    };
        parameters = @{@"grant_type": @"client_credentials"};
    }
    return self;
}

- (NSURLRequest *)toRequest {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: baseURL];
    request.timeoutInterval = timeout;
    request.HTTPMethod = [RESTMethod methodFrom: method];
    request.allHTTPHeaderFields = headers;
    NSMutableString *bodyString = [NSMutableString new];
    for (NSString *key in parameters.allKeys) {
        [bodyString appendFormat:@"%@=%@", key, [parameters valueForKey:key]];
    }
    request.HTTPBody = [bodyString dataUsingEncoding: NSUTF8StringEncoding];
    return request;
}


@end
