//
//  ATTNEventRequest.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-05-31.
//

import Foundation

// A single event can create multiple requests. The ATTNEventRequest class represents a single request.
final class ATTNEventRequest {
  var metadata: [String: Any]
  let eventNameAbbreviation: String
  var deeplink: String?

  init(metadata: [String: Any], eventNameAbbreviation: String) {
    self.metadata = metadata
    self.eventNameAbbreviation = eventNameAbbreviation
  }
}
