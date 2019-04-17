//
//  NSString+Base64.h
//  PayPalTest
//
//  Created by Javier on 4/17/19.
//  Copyright © 2019 GAIA Design. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Base64)

+ (instancetype)encodeBase64String:(NSString *)stringToEncode;
+ (instancetype)decodeBase64String:(NSString *)stringToDeccode;

@end
