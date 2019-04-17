//
//  OrderCreationResponse.m
//  PayPalTest
//
//  Created by Javier on 4/17/19.
//  Copyright © 2019 GAIA Design. All rights reserved.
//

#import "OrderCreationResponse.h"

@implementation OrderCreationResponse
@synthesize status;
@synthesize aprovementURL;
@synthesize orderId;

- (instancetype)initWithJSON: (NSDictionary *) json {
    self = [super init];
    if (self) {
        orderId = [json valueForKey:@"id"];
        status = [json valueForKey:@"status"];
        NSArray *links = [json objectForKey:@"links"];
        for (NSDictionary *dic in links) {
            if ([[dic valueForKey:@"rel"]isEqualToString:@"approve"]) {
                aprovementURL = [dic valueForKey:@"href"];
                break;
            }
        }
    }
    return self;
}
@end
