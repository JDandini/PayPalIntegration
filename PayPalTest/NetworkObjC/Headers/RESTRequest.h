//
//  RESTRequest.h
//  PayPalTest
//
//  Created by Javier on 4/17/19.
//  Copyright © 2019 GAIA Design. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "HTTPMethod.h"
#define kPayPalBase  @"https://api.sandbox.paypal.com"
@protocol RESTRequest <NSObject>
@required
@property(nonatomic, readwrite) HTTPMethod method;
@property(nonatomic, readwrite) NSString *path;
@property(nonatomic, readwrite) NSTimeInterval timeout;
@property(nonatomic, readwrite) NSURL *baseURL;

@optional
@property(nonatomic, readwrite) NSDictionary *headers;
@property(nonatomic, readwrite) NSDictionary *parameters;

-(NSURLRequest *) toRequest;
@end
