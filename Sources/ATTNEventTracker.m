//
//  ATTNEventTracker.m
//  attentive-ios-sdk
//
//  Created by Wyatt Davis on 12/7/22.
//

#import "ATTNEventTracker.h"
#import "attentive_ios_sdk_framework/attentive_ios_sdk_framework-Swift.h"
#import "ATTNAPI.h"

static ATTNEventTracker* __sharedInstance = nil;

@implementation ATTNEventTracker {
  ObjcATTNSDK* _sdk;
}

+ (void)setupWithSdk:(ObjcATTNSDK*)sdk {
  static dispatch_once_t ensureOnlyOnceToken;
  dispatch_once(&ensureOnlyOnceToken, ^{
    __sharedInstance = [[self alloc] initWithSdk:sdk];
  });
}

- (id)initWithSdk:(ObjcATTNSDK*)sdk {
  if (self = [super init]) {
    _sdk = sdk;
  }

  return self;
}

- (void)recordEvent:(id<ATTNEvent>)event {
  // TODO: Would be good to clone the UserIdentity so any changes to UserIdentity from another thread don't interfere with the API code
  [[_sdk getApi] sendEvent:event userIdentity:[_sdk getUserIdentity]];
}

+ (instancetype)sharedInstance {
  NSAssert(__sharedInstance != nil, @"ATTNEventTracker must be setup before being used");
  return __sharedInstance;
}

@end
