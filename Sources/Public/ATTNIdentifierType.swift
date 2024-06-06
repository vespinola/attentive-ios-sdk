//
//  ATTNIdentifierType.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-06-03.
//

import Foundation

@objc public class ATTNIdentifierType: NSObject {
  @objc public static let clientUserId = "clientUserId"
  @objc public static let phone = "phone"
  @objc public static let email = "email"
  @objc public static let shopifyId = "shopifyId"
  @objc public static let klaviyoId = "klaviyoId"
  @objc public static let customIdentifiers = "customIdentifiers"
}

// MARK: Internal Helpers
extension ATTNIdentifierType {
  static var allKeys: [String] = [
    clientUserId,
    phone,
    email,
    shopifyId,
    klaviyoId,
  ]
}
