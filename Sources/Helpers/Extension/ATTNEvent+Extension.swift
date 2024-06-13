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
    guard let provider = self as? ATTNEventRequestProvider else {
      NSLog("ERROR: Unknown event type: \(type(of: self))")
      return []
    }

    return provider.eventRequests
  }

  var priceFormatter: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = 2
    return formatter
  }
}
