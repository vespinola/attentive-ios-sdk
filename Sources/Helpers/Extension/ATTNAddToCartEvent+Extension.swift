//
//  ATTNAddToCartEvent+Extension.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-06-03.
//

import Foundation

extension ATTNAddToCartEvent: ATTNEventRequestProvider {
  var eventRequests: [ATTNEventRequest] {
    var eventRequests = [ATTNEventRequest]()

    if items.isEmpty {
      Loggers.event.error("No items found in the AddToCart event.")
      return []
    }

    for item in items {
      var metadata = [String: Any]()
      item.addItem(toDictionary: &metadata, with: priceFormatter)
      eventRequests.append(.init(metadata: metadata, eventNameAbbreviation: ATTNEventTypes.addToCart))
    }

    return eventRequests
  }
}
