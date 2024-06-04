//
//  ATTNUserAgentBuilderTests.swift
//  attentive-ios-sdk Tests
//
//  Created by Vladimir - Work on 2024-06-04.
//

import XCTest
@testable import attentive_ios_sdk_framework

final class ATTNUserAgentBuilderTests: XCTestCase {

  private var appInfoMock: ATTNAppInfoMock.Type!

  override func setUp() {
    super.setUp()
    appInfoMock = ATTNAppInfoMock.self
  }

  override func tearDown() {
    appInfoMock = nil
    super.tearDown()
  }

  func testBuildUserAgent_appInfoReturnsAllValues_userAgentIsFormattedCorrectly() {
    let actualUserAgent = ATTNUserAgentBuilder.buildUserAgent(appInfo: appInfoMock)

    XCTAssertEqual("appName-Value/appVersionValue.appBuildValue (deviceModelNameValue; devicePlatformValue deviceOsVersionValue) sdkNameValue/sdkVersionValue", actualUserAgent)
  }
}
