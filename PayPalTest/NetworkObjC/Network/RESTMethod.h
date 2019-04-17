//
//  RESTMethod.h
//  PayPalTest
//
//  Created by Javier on 4/17/19.
//  Copyright © 2019 GAIA Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPMethod.h"

@interface RESTMethod : NSObject
+(NSString *) methodFrom:(HTTPMethod) method;
@end
