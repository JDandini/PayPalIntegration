//
//  NSString+Base64.m
//  PayPalTest
//
//  Created by Javier on 4/17/19.
//  Copyright © 2019 GAIA Design. All rights reserved.
//

#import "NSString+Base64.h"

@implementation NSString (Base64)

+ (instancetype)encodeBase64String:(NSString *)stringToEncode
{
    NSData *dataToEncode = [stringToEncode dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encodedData = [dataToEncode base64EncodedDataWithOptions:0];
    NSString *encodedString = [[NSString alloc] initWithData:encodedData encoding:NSUTF8StringEncoding];

    return encodedString;
}

+ (instancetype)decodeBase64String:(NSString *)stringToDeccode
{
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:stringToDeccode options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];

    return decodedString;
}

@end
