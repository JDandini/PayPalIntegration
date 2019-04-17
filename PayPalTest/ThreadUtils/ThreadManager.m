//
//  ThreadManager.m
//  GAIA
//
//  Created by Javier on 1/9/19.
//  Copyright © 2019 Pop Up Design S de RL de CV. All rights reserved.
//

#import "ThreadManager.h"

@implementation ThreadManager
+ (void) asyncThreadWith: (ThreadCompletion)completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completion);
}

+ (void)mainAsyncThreadWith:(ThreadCompletion)completion {
    dispatch_async(dispatch_get_main_queue(), completion);
}
@end
