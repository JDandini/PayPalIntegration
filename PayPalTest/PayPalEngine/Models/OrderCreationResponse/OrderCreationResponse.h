//
//  OrderCreationResponse.h
//  PayPalTest
//
//  Created by Javier on 4/17/19.
//  Copyright © 2019 GAIA Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Serializable.h"

@interface OrderCreationResponse : NSObject <Serializable>
@property(nonatomic) NSString *orderId;
@property(nonatomic) NSString *status;
@property(nonatomic) NSString *aprovementURL;

@end

