//
//  Network.h
//  PayPalTest
//
//  Created by Javier on 4/17/19.
//  Copyright © 2019 GAIA Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RESTRequest.h"

@interface Network : NSObject
+(void)execute: (id<RESTRequest>_Nonnull)request
   withSuccess: (void(^ _Nonnull)(id _Nonnull))success
       orError: (void(^ _Nonnull)(NSError *_Nonnull))error;
@end

