//
//  ATTNCustomEventTest.m
//  attentive-ios-sdk Tests
//
//  Created by Wyatt Davis on 4/14/23.
//

#import <XCTest/XCTest.h>
#import "attentive_ios_sdk_framework/attentive_ios_sdk_framework-Swift.h"

@interface ATTNCustomEventTest : XCTestCase

@end

@implementation ATTNCustomEventTest

- (void)setUp {
  // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testConstructor {
  XCTAssertNoThrow([[ATTNCustomEvent alloc] initWithType:nil properties:@{@"k" : @"v"}]);
  XCTAssertNoThrow([[ATTNCustomEvent alloc] initWithType:@"]" properties:@{@"k" : @"v"}]);
  XCTAssertNoThrow([[ATTNCustomEvent alloc] initWithType:@"good" properties:nil]);
  XCTAssertNoThrow([[ATTNCustomEvent alloc] initWithType:@"good" properties:@{@"k]" : @"v"}]);

  XCTAssertNoThrow([[ATTNCustomEvent alloc] initWithType:@"" properties:@{@"k" : @"v"}]);
  XCTAssertNoThrow([[ATTNCustomEvent alloc] initWithType:@"good" properties:@{}]);
  XCTAssertNoThrow([[ATTNCustomEvent alloc] initWithType:@"good" properties:@{@"k" : @"v"}]);
}

@end
