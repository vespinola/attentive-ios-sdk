//
//  ATTNCreativeUrlProviderSpy.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-06-14.
//

import Foundation
@testable import ATTNSDKFramework

final class ATTNCreativeUrlProviderSpy: ATTNCreativeUrlProviding {
  private(set) var buildCompanyCreativeUrlWasCalled = false
  private(set) var usedDomain: String?

  func buildCompanyCreativeUrl(forDomain domain: String, mode: String, userIdentity: ATTNSDKFramework.ATTNUserIdentity) -> String {
    buildCompanyCreativeUrlWasCalled = true
    usedDomain = domain
    return ""
  }
}