//
//  ATTUserIdentity.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-05-29.
//

import Foundation

@objc(ATTUserIdentity)
final class ATTUserIdentity: NSObject {
  private var identifiers: [String: Any] {
    willSet {
      validate(identifiers: newValue)
    }
  }

  private var visitorId: String
  private let visitorService: ATTNVisitorService

  override convenience init() {
    self.init(identifiers: [:])
  }

  @objc(initWithIdentifiers:)
  init(identifiers: [String: Any]) {
    self.visitorService = .init()
    self.identifiers = identifiers
    self.visitorId = self.visitorService.getVisitorId()
    super.init()
  }

  @objc
  func clearUser() {
    identifiers = [:]
    visitorId = visitorService.createNewVisitorId()
  }

  @objc
  func mergeIdentifiers(_ newIdentifiers: [String: Any]) {
    validate(identifiers: newIdentifiers)

    var currentIdentifiers = identifiers
    // In case of a key conflict, the new value from newIdentifiers should be used.
    currentIdentifiers.merge(newIdentifiers) { (_, new) in new }
    identifiers = currentIdentifiers
  }
}

fileprivate extension ATTUserIdentity {
  func validate(identifiers: [String: Any]) {
    let keys: [String] = [
      IDENTIFIER_TYPE_CLIENT_USER_ID,
      IDENTIFIER_TYPE_PHONE,
      IDENTIFIER_TYPE_EMAIL,
      IDENTIFIER_TYPE_SHOPIFY_ID,
      IDENTIFIER_TYPE_KLAVIYO_ID,
    ]

    keys.forEach { currentKey in
      ATTNParameterValidation.verifyStringOrNil(
        identifiers[currentKey] as? String,
        inputName: currentKey
      )
    }

    ATTNParameterValidation.verify1DStringDictionaryOrNil(
      identifiers[IDENTIFIER_TYPE_CUSTOM_IDENTIFIERS] as? [AnyHashable: Any],
      inputName: IDENTIFIER_TYPE_CUSTOM_IDENTIFIERS)
  }
}
