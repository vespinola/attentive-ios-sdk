//
//  ATTNUserAgentBuilderMock.swift
//  attentive-ios-sdk Tests
//
//  Created by Vladimir - Work on 2024-05-31.
//

import Foundation
@testable import attentive_ios_sdk_framework

class ATTNUserAgentBuilderMock: ATTNUserAgentBuilderProtocol {
  func buildUserAgent() -> String { "fakeUserAgent" }
}
