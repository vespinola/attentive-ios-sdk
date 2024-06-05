//
//  ATTNCreativeUrlFormatterTests.swift
//  attentive-ios-sdk Tests
//
//  Created by Vladimir - Work on 2024-06-04.
//

import XCTest
@testable import attentive_ios_sdk_framework

final class ATTNCreativeUrlFormatterTests: XCTestCase {

  private let TEST_DOMAIN = "testDomain"

  func testBuildCompanyCreativeUrlForDomain_productionMode_buildsProdUrl() {
    let userIdentity = ATTNUserIdentity(identifiers: [:])
    let url = ATTNCreativeUrlFormatter.buildCompanyCreativeUrl(forDomain: TEST_DOMAIN, mode: "production", userIdentity: userIdentity)

    let expectedUrl = "https://creatives.attn.tv/mobile-apps/index.html?domain=testDomain&vid=\(userIdentity.visitorId)&sdkVersion=\(ATTNAppInfo.getSdkVersion())&sdkName=attentive-ios-sdk"

    XCTAssertEqual(expectedUrl, url)
  }

  func testBuildCompanyCreativeUrlForDomain_productionMode_buildsDebugUrl() {
    let userIdentity = ATTNUserIdentity(identifiers: [:])
    let url = ATTNCreativeUrlFormatter.buildCompanyCreativeUrl(forDomain: TEST_DOMAIN, mode: "debug", userIdentity: userIdentity)

    let expectedUrl = "https://creatives.attn.tv/mobile-apps/index.html?domain=testDomain&debug=matter-trip-grass-symbol&vid=\(userIdentity.visitorId)&sdkVersion=\(ATTNAppInfo.getSdkVersion())&sdkName=attentive-ios-sdk"

    XCTAssertEqual(expectedUrl, url)
  }

  func testBuildCompanyCreativeUrlForDomain_withUserIdentifiers_buildsUrlWithIdentifierQueryParams() {
    let userIdentity = ATTNTestEventUtils.buildUserIdentity()
    let url = ATTNCreativeUrlFormatter.buildCompanyCreativeUrl(forDomain: TEST_DOMAIN, mode: "production", userIdentity: userIdentity)

    let expectedUrl = "https://creatives.attn.tv/mobile-apps/index.html?domain=testDomain&vid=\(userIdentity.visitorId)&cuid=someClientUserId&p=+14156667777&e=someEmail@email.com&kid=someKlaviyoId&sid=someShopifyId&cstm=%7B%22customId%22:%22customIdValue%22%7D&sdkVersion=\(ATTNAppInfo.getSdkVersion())&sdkName=attentive-ios-sdk"

    XCTAssertEqual(expectedUrl, url)
  }

  func testBuildCompanyCreativeUrlForDomain_productionMode_buildsUrlWithSdkDetails() {
    let userIdentity = ATTNUserIdentity(identifiers: [:])

    let url = ATTNCreativeUrlFormatter.buildCompanyCreativeUrl(forDomain: TEST_DOMAIN, mode: "production", userIdentity: userIdentity)

    let expectedUrl = "https://creatives.attn.tv/mobile-apps/index.html?domain=testDomain&vid=\(userIdentity.visitorId)&sdkVersion=\(ATTNConstants.sdkVersion)&sdkName=attentive-ios-sdk"

    XCTAssertEqual(expectedUrl, url)
  }
}
