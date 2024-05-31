//
//  ATTNUserAgentBuilderMock.swift
//  attentive-ios-sdk Tests
//
//  Created by Vladimir - Work on 2024-05-31.
//

import Foundation

@objc
class ATTNUserAgentBuilderMock: ATTNUserAgentBuilder {
  override class func buildUserAgent() -> String { "fakeUserAgent" }
}
