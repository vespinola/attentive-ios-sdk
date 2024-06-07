//
//  SMSPage.swift
//  CreativeUITest
//
//  Created by Vladimir - Work on 2024-06-05.
//

import XCTest

struct SMSPage: Page {
  private init() { }

  @discardableResult
  static func verifyPrefilledMessage(message: String) -> Self.Type {
    guard let prefilledMessage = messageTextView.value as? String else {
      return self
    }

    guard prefilledMessage.contains(message) else {
      XCTFail("Prefilled message does not contain '\(message)'")
      return self
    }

    return self
  }
}

fileprivate extension SMSPage {
  static var messageTextView: XCUIElement {
    smsApp.textFields["Message"]
  }
}
