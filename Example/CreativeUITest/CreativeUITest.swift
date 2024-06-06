//
//  CreativeUITest.swift
//  CreativeUITest
//
//  Created by Vladimir - Work on 2024-06-05.
//

import XCTest
import WebKit

final class CreativeUITest: XCTestCase, BaseXCTestCase {
  override func setUp() {
    super.setUp()
    continueAfterFailure = false
  }

  override func tearDown() {
    clearCookies()
    resetUserDefaults()

    XCUIApplication().terminate()

    deleteApp()

    super.tearDown()
  }

  func testLoadCreative_clickClose_closesCreative() {
    launch(with: .production)

    HomePage
      .tapOnPushMeToCreative()
      .addDelay(seconds: 2)

    CreativePage.tapOnCloseCreative()

    HomePage.verifyPushMeToCreativeIsHittable()
  }

  func testLoadCreative_fillOutFormAndSubmit_launchesSmsAppWithPrePopulatedText() {
    launch(with: .production)

    HomePage
      .tapOnClearUser()
      .tapOnPushMeToCreative()

    CreativePage
      .fillEmailInput(text: "testemail@attentivemobile.com")
      .dismissKeyboard()
      .tapOnContinue()
      .tapOnSubscribe()

    guard canLaunchExternalApps else { return }
    
    SMSPage
      .verifyPrefilledMessage(
        message: "Send this text to subscribe to recurring automated personalized marketing alerts (e.g. cart reminders) from Attentive Mobile Apps Test"
      )
  }

  func testLoadCreative_clickPrivacyLink_opensPrivacyPageInWebApp() {
    launch(with: .production)

    HomePage.tapOnPushMeToCreative()

    CreativePage
      .tapOnPrivacyLink()
      .addDelay(seconds: 5)

    guard canLaunchExternalApps else { return }

    PricacyPolicyPage.verifyContent()
  }

  func testLoadCreative_inDebugMode_showsDebugMessage() {
    launch(with: .debug)

    HomePage.tapOnPushMeToCreative()

    CreativePage.verifyDebugPage()
  }

  func testLoadCreative_clickProductPage_closesCreative() {
    launch(with: .production)

    HomePage.tapOnPushMeToCreative()

    CreativePage.verifyPrivacyLinkExists()

    HomePage.navigateToProduct()

    ProductPage
      .tapOnAddToCart()
      .navigateToMain()

    HomePage.verifyPushMeToCreativeIsHittable()
  }
}

extension CreativeUITest {
  func clearCookies() {
    print("Clearing cookies!")
    let websiteDataTypes: Set<String> = [WKWebsiteDataTypeCookies]
    let dateFrom = Date(timeIntervalSince1970: .zero)

    WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes, modifiedSince: dateFrom) {
      print("Cleared cookies!")
    }
  }

  func resetUserDefaults() {
    // Reset user defaults for example app, not the test runner
    UserDefaults.standard.removePersistentDomain(forName: "com.attentive.ExampleTest")
  }
}
