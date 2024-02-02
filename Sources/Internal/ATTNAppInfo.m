//
//  AppInfo.m
//  attentive-ios-sdk-framework
//
//  Created by Wyatt Davis on 3/14/23.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#endif

#import "ATTNAppInfo.h"
#import "ATTNVersion.h"

@implementation ATTNAppInfo

+ (NSString *)getAppBuild {
  return [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
}
+ (NSString *)getAppVersion {
  return [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
}
+ (NSString *)getAppName {
  return [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
}
+ (NSString *)getAppId {
  return [[NSBundle mainBundle] bundleIdentifier];
}

+ (NSString *)getDeviceModelName {
  #if TARGET_OS_IOS
    return [[UIDevice currentDevice] model];
  #else
    return @"Not iOS device, not supported";
  #endif
}

+ (NSString *)getDevicePlatform {
  #if TARGET_OS_IOS
    return [[UIDevice currentDevice] systemName];
  #else
    return @"Not iOS device, not supported";
  #endif
}

+ (NSString *)getDeviceOsVersion {
  return [[NSProcessInfo processInfo] operatingSystemVersionString];
}

+ (NSString *)getSdkName {
  return @"attentive-ios-sdk";
}

+ (NSString *)getSdkVersion {
  return SDK_VERSION;
}

@end
