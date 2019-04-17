//
//  ThreadManager.h
//  GAIA
//
//  Created by Javier on 1/9/19.
//  Copyright © 2019 Pop Up Design S de RL de CV. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^ThreadCompletion)(void);

@interface ThreadManager : NSObject
+ (void) asyncThreadWith: (ThreadCompletion)completion;
+ (void) mainAsyncThreadWith: (ThreadCompletion)completion;
@end
