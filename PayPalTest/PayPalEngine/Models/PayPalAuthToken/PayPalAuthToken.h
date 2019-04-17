//
//  PayPalAuthToken.h
//  PayPalTest
//
//  Created by Javier on 4/17/19.
//  Copyright © 2019 GAIA Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Serializable.h"

@interface PayPalAuthToken : NSObject <Serializable>
@property(nonatomic) NSString *token;
@property(nonatomic) NSString *appId;
@property(nonatomic, assign) NSTimeInterval expirationTime;

@end

