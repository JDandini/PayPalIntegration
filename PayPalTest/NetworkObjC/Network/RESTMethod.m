//
//  RESTMethod.m
//  PayPalTest
//
//  Created by Javier on 4/17/19.
//  Copyright © 2019 GAIA Design. All rights reserved.
//

#import "RESTMethod.h"

@implementation RESTMethod

+(NSString *) methodFrom:(HTTPMethod) method {
    switch (method) {
        case HTTPMethodPOST:
            return  @"POST";
        case HTTPMethodGET:
            return @"GET";
        case HTTPMethodPATCH:
            return @"PATCH";
        default:
            return  nil;
    }
}
@end
