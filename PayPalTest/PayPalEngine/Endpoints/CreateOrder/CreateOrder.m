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

        parameters = [self createPaymentDictionary];
    }
    return self;
}

-(NSDictionary *)createPaymentDictionary {
    NSMutableDictionary *resutlValue = [NSMutableDictionary new];
    [resutlValue setObject:@"CAPTURE" forKey:@"intent"];
    NSDictionary *context = @{
                              @"return_url": @"https://gaiadesign.com.mx",
                              @"cancel_url": @"https://gaiadesign.com.mx/cancel",
                              @"brand_name": @"GAIA Design",
                              @"locale": @"es-MX",
                              @"landing_page": @"LOGIN",
                              @"shipping_preference": @"SET_PROVIDED_ADDRESS",
                              @"user_action": @"CONTINUE"
                              };
    [resutlValue setObject:context forKey:@"application_context"];
    NSMutableDictionary *purchaseUnits = [NSMutableDictionary new];
    [purchaseUnits setObject:@"GAIA" forKey:@"reference_id"];
    [purchaseUnits setObject:@"GAIA Design" forKey:@"description"];
    [purchaseUnits setObject:@"GAIA-Design" forKey:@"custom_id"];
    [purchaseUnits setObject:@"MueblesGAIA" forKey:@"soft_descriptor"];
    NSDictionary *amount = @{
                             @"currency_code": @"MXN",
                             @"value" : @1000.00,
                             @"breakdown": @{
                                     @"item_total": @{
                                             @"currency_code": @"MXN",
                                             @"value": @"1000.00"
                                             },
                                     @"shipping": @{
                                             @"currency_code": @"MXN",
                                             @"value": @"0.00"
                                             }
                                     }
                             };
    [purchaseUnits setObject:amount forKey:@"amount"];
    NSArray *items = @[@{
                           @"name": @"Silla Eames",
                           @"description": @"Silla Eames blanca",
                           @"sku": @"sku01",
                           @"unit_amount": @{
                                   @"currency_code": @"MXN",
                                   @"value": @"100.00"
                                   },
                           @"quantity": @"10",
                           @"category": @"PHYSICAL_GOODS"
                           },
                       ];
    [purchaseUnits setObject:items forKey:@"items"];
    NSDictionary *shipping = @{
                               @"method": @"GAIA Delivery",
                               @"address": @{
                                       @"address_line_1": @"Radamés Gaxiola Andrade 548",
                                       @"address_line_2": @"PB",
                                       @"admin_area_2": @"Ciudad de México",
                                       @"admin_area_1": @"DF",
                                       @"postal_code": @"09060",
                                       @"country_code": @"MX"
                                       }
                               };
    [purchaseUnits setObject:shipping forKey:@"shipping"];
    [resutlValue setObject:@[purchaseUnits] forKey:@"purchase_units"];
    return resutlValue;
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
