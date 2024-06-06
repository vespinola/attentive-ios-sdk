//
//  ATTNUserAgentBuilderTest.m
//  attentive-ios-sdk Tests
//
//  Created by Wyatt Davis on 3/14/23.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "attentive_ios_sdk_framework/attentive_ios_sdk_framework-Swift.h"
#import "attentive_ios_sdk_Tests-Swift.h"

@interface ATTNUserAgentBuilderTest : XCTestCase

@end


@implementation ATTNUserAgentBuilderTest {
  id _appInfoMock;
}

- (void)setUp {
  _appInfoMock = [ATTNAppInfoMock class];
}

- (void)tearDown {
  _appInfoMock = nil;
}

- (void)testBuildUserAgent_appInfoReturnsAllValues_userAgentIsFormattedCorrectly {
  NSString* actualUserAgent = [ATTNUserAgentBuilder buildUserAgentWithAppInfo:_appInfoMock];

  XCTAssertEqualObjects(@"appName-Value/appVersionValue.appBuildValue (deviceModelNameValue; devicePlatformValue deviceOsVersionValue) sdkNameValue/sdkVersionValue", actualUserAgent);
}

@end
