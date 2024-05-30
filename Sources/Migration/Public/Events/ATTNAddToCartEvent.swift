//
//  ATTNAddToCartEvent.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-05-30.
//

import Foundation

@objc(ATTNAddToCartEvent)
public final class ATTNAddToCartEvent: NSObject, ATTNEvent {
  @objc public let items: [ATTNItem]

  // Public initializer
  @objc 
  public init(items: [ATTNItem]) {
    self.items = items
    super.init()
  }

  // Private default initializer to prevent its use
  @objc private override init() {
    fatalError("init() has not been implemented")
  }
}
