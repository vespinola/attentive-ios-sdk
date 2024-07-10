//
//  ATTNProductViewEvent.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-05-30.
//

import Foundation

@objc(ATTNProductViewEvent)
public final class ATTNProductViewEvent: NSObject, ATTNEvent {
  @objc public let items: [ATTNItem]
  @objc public var deeplink: String?

  @objc(initWithItems:)
  public init(items: [ATTNItem]) {
    self.items = items
    super.init()
  }

  private override init() {
    fatalError("init() has not been implemented")
  }
}

extension ATTNProductViewEvent: ATTNDeeplinkHandling { }
