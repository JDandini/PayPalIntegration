//
//  Network.m
//  PayPalTest
//
//  Created by Javier on 4/17/19.
//  Copyright © 2019 GAIA Design. All rights reserved.
//

#import "Network.h"
#import "ThreadManager.h"
#import <UIKit/UIKit.h>

@implementation Network

+ (void)execute:(id<RESTRequest>)request
    withSuccess:(void (^)(id _Nonnull))success
        orError:(void (^)(NSError * _Nonnull))errorCompletion {
    NSURLRequest *urlRequest = [request toRequest];
    if (urlRequest == nil) {
        NSError *requestError = [NSError errorWithDomain: @"EmptyRequest"
                                                    code: 999
                                                userInfo: @{NSLocalizedDescriptionKey: @"There is no request"}];
        errorCompletion(requestError);
        return;
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
    [ThreadManager asyncThreadWith: ^{
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            [ThreadManager mainAsyncThreadWith:^{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
            }];
            if (error != nil) {
                errorCompletion(error);
                return;
            }
            if (data == nil || data.length == 0) {
                NSError *requestError = [NSError errorWithDomain: @"EmptyResponse"
                                                            code: 999
                                                        userInfo: @{NSLocalizedDescriptionKey: @"No data at response"}];
                errorCompletion(requestError);
                return;
            }
            NSError *serializationError = nil;
            id jsonResponse = [NSJSONSerialization JSONObjectWithData: data
                                                              options: NSJSONReadingAllowFragments
                                                                error: &serializationError];
            if (serializationError != nil) {
                errorCompletion(serializationError);
                return;
            }
            success(jsonResponse);
        }];
        [task resume];
    }];
}

@end
