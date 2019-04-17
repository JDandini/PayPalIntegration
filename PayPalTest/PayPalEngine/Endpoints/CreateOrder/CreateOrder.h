//
//  CreateOrder.h
//  PayPalTest
//
//  Created by Javier on 4/17/19.
//  Copyright © 2019 GAIA Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RESTRequest.h"

@interface CreateOrder : NSObject<RESTRequest>
- (instancetype)initWithToken: (NSString *)token andAmount: (double) amount;
@end
