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

#import "YXLError.h"
#import "YXLLoginResult.h"
#import "YXLObserver.h"
#import "YXLSdk.h"
#import "YandexLoginSDK.h"

FOUNDATION_EXPORT double YandexLoginSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char YandexLoginSDKVersionString[];

