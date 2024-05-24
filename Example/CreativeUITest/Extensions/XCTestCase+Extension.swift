//
//  XCTestCase+Extension.swift
//  CreativeUITest
//
//  Created by Vladimir - Work on 2024-05-23.
//

import XCTest

extension XCTestCase {
  @objc func deleteApp() {
    let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    let icon = springboard.icons["Example - Local"]

    guard icon.exists else { return }

    icon.press(forDuration: 1)

    springboard.buttons["Remove App"].tapOnElement()
    springboard.buttons["Delete App"].tapOnElement()
    springboard.buttons["Delete"].tapOnElement()
  }
}
