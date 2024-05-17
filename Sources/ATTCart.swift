//
//  ATTCart.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-05-16.
//

import Foundation

public struct ATTCart {
  public var cartId: String?
  public var cartCoupon: String?
  
  public init(cartId: String? = nil, cartCoupon: String? = nil) {
    self.cartId = cartId
    self.cartCoupon = cartCoupon
  }
}

//For Objective-C
@objc(ATTCart)
public class ObjcATTCart: NSObject {
  private var cart: ATTCart
  
  @objc(initWithCartId:andCartCoupon:)
  public init(cardId: String?, cartCoupon: String?) {
    self.cart = ATTCart(cartId: cardId, cartCoupon: cartCoupon)
  }
  
  @objc public var cartCoupon: String? {
    set {
      cart.cartCoupon = newValue
    }
    get {
      cart.cartCoupon
    }
  }
}
