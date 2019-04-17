//
//  CreateOrder.m
//  PayPalTest
//
//  Created by Javier on 4/17/19.
//  Copyright © 2019 GAIA Design. All rights reserved.
//

#import "CreateOrder.h"
#import "RESTMethod.h"

@implementation CreateOrder
@synthesize baseURL;
@synthesize method;
@synthesize path;
@synthesize timeout;
@synthesize parameters;
@synthesize headers;

- (instancetype)initWithToken: (NSString *)token andAmount: (double) amount {
    self = [super init];
    if (self) {
        path = @"/v2/checkout/orders";
        method = HTTPMethodPOST;
        timeout = 15;
        NSString *urlString = [NSString stringWithFormat:@"%@%@", kPayPalBase, path];
        baseURL = [NSURL URLWithString:urlString];
        headers = @{@"Content-Type": @"application/json",
                    @"Authorization": [NSString stringWithFormat:@"Bearer %@",token]
                    };
        NSMutableDictionary *mutableParams = [NSMutableDictionary new];
        [mutableParams setObject:@"CAPTURE" forKey:@"intent"];
        NSNumber *numberWithAmount = [NSNumber numberWithDouble: amount];
        NSDictionary *amountObject = @{ @"currency_code": @"MXN",
                                  @"value": numberWithAmount
                                  };
        NSArray *purchaseUnits = @[@{@"amount": amountObject}];
        [mutableParams setObject:purchaseUnits forKey:@"purchase_units"];
        parameters = mutableParams;
    }
    return self;
}

- (NSURLRequest *)toRequest {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: baseURL];
    request.timeoutInterval = timeout;
    request.HTTPMethod = [RESTMethod methodFrom: method];
    request.allHTTPHeaderFields = headers;
    NSError *serializeError = nil;
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters
                                                       options:NSJSONWritingPrettyPrinted
                                                         error: &serializeError];
    if (serializeError != nil) {
        return nil;
    }
    return request;
}
@end
