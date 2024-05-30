//
//  ATTNItem.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-05-30.
//

import Foundation

@objc(ATTNItem)
public final class ATTNItem: NSObject {
  @objc public let productId: String
  @objc public let productVariantId: String
  @objc public let price: ATTNPrice
  @objc public var quantity: Int
  @objc public var productImage: String?
  @objc public var name: String?
  @objc public var category: String?

  @objc(initWithProductId:productVariantId:price:)
  public init(productId: String, productVariantId: String, price: ATTNPrice) {
    self.productId = productId
    self.productVariantId = productVariantId
    self.price = price
    self.quantity = 1
  }
}
