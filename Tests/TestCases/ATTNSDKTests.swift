//
//  ATTNSDKTests.swift
//  attentive-ios-sdk Tests
//
//  Created by Vladimir - Work on 2024-06-13.
//

import XCTest
@testable import ATTNSDKFramework

final class ATTNSDKTests: XCTestCase {
  private var sut: ATTNSDK!
  private var apiSpy: ATTNAPISpy!
  private let testDomain = "TEST_DOMAIN"

  override func setUp() {
    super.setUp()
    apiSpy = ATTNAPISpy(domain: testDomain)
    sut = ATTNSDK(api: apiSpy)
  }

  override func tearDown() {
    sut = nil
    apiSpy = nil
    super.tearDown()
  }

  func testUpdateDomain_newDomain_willUpdateAPIDomainProperty() {
    let newDomain = "NEW_DOMAIN"
    
    XCTAssertFalse(apiSpy.updateDomainWasCalled)
    XCTAssertEqual(apiSpy.domain, testDomain)

    sut.update(domain: newDomain)

    XCTAssertTrue(apiSpy.updateDomainWasCalled)
    XCTAssertTrue(apiSpy.domainWasSetted)
    XCTAssertTrue(apiSpy.sendUserIdentityWasCalled)
    
    XCTAssertEqual(apiSpy.domain, newDomain)
  }

  func testUpdateDomain_sameDomain_willNotUpdateAPIDomainProperty() {
    XCTAssertFalse(apiSpy.updateDomainWasCalled)
    XCTAssertEqual(apiSpy.domain, testDomain)

    sut.update(domain: testDomain)

    XCTAssertFalse(apiSpy.updateDomainWasCalled)
    XCTAssertFalse(apiSpy.domainWasSetted)
    XCTAssertFalse(apiSpy.sendUserIdentityWasCalled)

    XCTAssertEqual(apiSpy.domain, testDomain)
  }

//  func testUpdateDomain_newDomain_willUpdateCreativeURL() {
//    XCTAssertFalse(apiSpy.updateDomainWasCalled)
//    XCTAssertEqual(apiSpy.domain, testDomain)
//
//    sut.update(domain: testDomain)
//
//    XCTAssertEqual(apiSpy.domain, testDomain)
//
//    
//  }
}

