//
//  ATTNAddToCartEventTests.swift
//  attentive-ios-sdk Tests
//
//  Created by Vladimir - Work on 2024-07-11.
//

import XCTest
@testable import ATTNSDKFramework

final class ATTNAddToCartEventTests: XCTestCase {
  func testAddCart_GivenData_ShouldBuildURL() {
    let item = ATTNTestEventUtils.buildItem()
    let addToCart = ATTNAddToCartEvent(items: [item])
    XCTAssertFalse(addToCart.eventRequests.isEmpty)
    XCTAssertNil(addToCart.eventRequests.first?.metadata["requestURL"])
  }

  func testAddCart_GivenData_ShouldBuildURLWithRequestURL() {
    let item = ATTNTestEventUtils.buildItem()
    let addToCart = ATTNAddToCartEvent(items: [item])
    addToCart.deeplink = "https://www.clientapp.com/flow=payment"
    XCTAssertFalse(addToCart.eventRequests.isEmpty)
    let requestURL = addToCart.eventRequests.first?.metadata["requestURL"] as? String
    XCTAssertNotNil(requestURL)
    XCTAssertFalse(requestURL?.isEmpty ?? true)
  }
}
