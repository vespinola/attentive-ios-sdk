//
//  ATTNProductViewEvent+Extension.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-06-03.
//

import Foundation

extension ATTNProductViewEvent: ATTNEventRequestProvider {
  var eventRequests: [ATTNEventRequest] {
    var eventRequests = [ATTNEventRequest]()

    if items.isEmpty {
      Loggers.event.debug("No items found in the ProductView event.")
      return []
    }

    for item in items {
      var metadata = [String: Any]()
      item.addItem(toDictionary: &metadata, with: priceFormatter)

      if let deeplink {
        metadata["pd"] = deeplink
      }

      eventRequests.append(.init(metadata: metadata, eventNameAbbreviation: ATTNEventTypes.productView))
    }

    return eventRequests
  }
}
