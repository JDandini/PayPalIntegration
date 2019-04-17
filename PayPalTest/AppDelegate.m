//
//  AppDelegate.m
//  PayPalTest
//
//  Created by Javier on 4/16/19.
//  Copyright © 2019 GAIA Design. All rights reserved.
//

#import "AppDelegate.h"
#import <NativeCheckout/PYPLCheckout.h>

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [[PYPLCheckout sharedInstance] handleReturnFromPaypal: url];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    return [[PYPLCheckout sharedInstance] application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
}

- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame {
    [[PYPLCheckout sharedInstance] application:application didChangeStatusBarFrame:oldStatusBarFrame];
}

@end
