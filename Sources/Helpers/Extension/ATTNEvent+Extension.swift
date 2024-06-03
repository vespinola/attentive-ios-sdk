//
//  ATTNEvent+Extension.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-06-03.
//

import Foundation

// MARK: Internal Helpers
extension ATTNEvent {
  func convertEventToRequests() -> [ATTNEventRequest] {
    var eventRequests = [ATTNEventRequest]()

    if let purchase = self as? ATTNPurchaseEvent {
      if purchase.items.isEmpty {
        NSLog("No items found in the purchase event.")
        return []
      }

      var cartTotal = NSDecimalNumber.zero
      for item in purchase.items {
        var metadata = [String: Any]()
        item.addItem(toDictionary: &metadata, with: priceFormatter)
        metadata["orderId"] = purchase.order.orderId

        if let cart = purchase.cart {
          metadata.addEntryIfNotNil(key: "cartId", value: cart.cartId)
          metadata.addEntryIfNotNil(key: "cartCoupon", value: cart.cartCoupon)
        }

        eventRequests.append(ATTNEventRequest(metadata: metadata, eventNameAbbreviation: ATTNEventTypes.purchase))

        cartTotal = cartTotal.adding(item.price.price)
      }

      let cartTotalString = priceFormatter.string(from: cartTotal)
      for eventRequest in eventRequests {
        eventRequest.metadata["cartTotal"] = cartTotalString
      }

      var orderConfirmedMetadata = [String: Any]()
      orderConfirmedMetadata["orderId"] = purchase.order.orderId
      orderConfirmedMetadata["cartTotal"] = cartTotalString
      orderConfirmedMetadata["currency"] = purchase.items.first?.price.currency

      var products = [[String: Any]]()
      for item in purchase.items {
        var product = [String: Any]()
        item.addItem(toDictionary: &product, with: priceFormatter)
        products.append(product)
      }
      orderConfirmedMetadata["products"] = try? ATTNJsonUtils.convertObjectToJson(products) ?? "[]"
      eventRequests.append(ATTNEventRequest(metadata: orderConfirmedMetadata, eventNameAbbreviation: ATTNEventTypes.orderConfirmed))

      return eventRequests
    } else if let addToCart = self as? ATTNAddToCartEvent {
      if addToCart.items.isEmpty {
        NSLog("No items found in the AddToCart event.")
        return []
      }

      for item in addToCart.items {
        var metadata = [String: Any]()
        item.addItem(toDictionary: &metadata, with: priceFormatter)
        eventRequests.append(ATTNEventRequest(metadata: metadata, eventNameAbbreviation: ATTNEventTypes.addToCart))
      }

      return eventRequests
    } else if let productView = self as? ATTNProductViewEvent {
      if productView.items.isEmpty {
        NSLog("No items found in the ProductView event.")
        return []
      }

      for item in productView.items {
        var metadata = [String: Any]()
        item.addItem(toDictionary: &metadata, with: priceFormatter)
        eventRequests.append(ATTNEventRequest(metadata: metadata, eventNameAbbreviation: ATTNEventTypes.productView))
      }

      return eventRequests
    } else if self is ATTNInfoEvent {
      eventRequests.append(ATTNEventRequest(metadata: [String: Any](), eventNameAbbreviation: ATTNEventTypes.info))
      return eventRequests
    } else if let customEvent = self as? ATTNCustomEvent {
      var customEventMetadata = [String: Any]()
      customEventMetadata["type"] = customEvent.type
      customEventMetadata["properties"] =  try? ATTNJsonUtils.convertObjectToJson(customEvent.properties) ?? "{}"

      eventRequests.append(ATTNEventRequest(metadata: customEventMetadata, eventNameAbbreviation: ATTNEventTypes.customEvent))
      return eventRequests

    } else {
      NSLog("ERROR: Unknown event type: \(type(of: self))")
      return []
    }
  }
}

// MARK: Private Helpers
fileprivate extension ATTNEvent {
  var priceFormatter: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = 2
    return formatter
  }
}
