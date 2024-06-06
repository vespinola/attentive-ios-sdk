//
//  Screen.swift
//  CreativeUITest
//
//  Created by Vladimir - Work on 2024-06-05.
//

import XCTest

enum Mode: String {
  case debug
  case production
}

protocol BaseXCTestCase where Self: XCTestCase {
  func deleteApp()
  func launch(with mode: Mode)
}

extension BaseXCTestCase {
  func deleteApp() {
    let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    let icon = springboard.icons["Example - Local"]

    guard icon.exists else { return }

    icon.press(forDuration: 1)

    springboard.buttons["Remove App"].tapOnElement()
    springboard.buttons["Delete App"].tapOnElement()
    springboard.buttons["Delete"].tapOnElement()
  }

  func launch(with mode: Mode) {
    let app = XCUIApplication()
    app.launchEnvironment = [
      "COM_ATTENTIVE_EXAMPLE_DOMAIN" : "mobileapps",
      "COM_ATTENTIVE_EXAMPLE_MODE" : mode.rawValue,
      "COM_ATTENTIVE_EXAMPLE_IS_UI_TEST" : "YES",
    ]
    app.launch()
  }

  var canLaunchExternalApps: Bool {
    // Assert that the SMS app is opened with prepopulated text if running locally
    // (AWS Device Farm doesn't allow use of SMS apps)
    ProcessInfo
      .processInfo
      .environment["COM_ATTENTIVE_EXAMPLE_HOST"] == "local"
  }
}