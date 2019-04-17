#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "SyrAlertDialogue.h"
#import "SyrAnimatedImage.h"
#import "SyrAnimatedText.h"
#import "SyrAnimatedView.h"
#import "SyrAnimationDelegate.h"
#import "SyrAnimator.h"
#import "SyrBridge.h"
#import "SyrBundleManager.h"
#import "SyrButton.h"
#import "SyrComponent.h"
#import "SyrCore.h"
#import "SyrEventHandler.h"
#import "SyrHapticHelper.h"
#import "SyrHeightWidthAnimation.h"
#import "SyrImage.h"
#import "SyrInfoBox.h"
#import "SyrLinearGradient.h"
#import "SyrNative.h"
#import "SyrNetworking.h"
#import "SyrOpacityAnimation.h"
#import "SyrRaster.h"
#import "SyrRootView.h"
#import "SyrRotationAnimation.h"
#import "SyrScrollView.h"
#import "SyrStackView.h"
#import "SyrStyler.h"
#import "SyrSwitch.h"
#import "SyrText.h"
#import "SyrTouchableOpacity.h"
#import "SyrView.h"
#import "SyrViewHandler.h"
#import "SyrXYAnimation.h"

FOUNDATION_EXPORT double syr_coreVersionNumber;
FOUNDATION_EXPORT const unsigned char syr_coreVersionString[];

