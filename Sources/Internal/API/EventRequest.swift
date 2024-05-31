//
//  EventRequest.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-05-31.
//

import Foundation

// A single event can create multiple requests. The EventRequest class represents a single request.
@objc(EventRequest)
public final class EventRequest: NSObject {
  @objc public var metadata: [String: Any]
  @objc public let eventNameAbbreviation: String

  @objc(initWithMetadata:eventNameAbbreviation:)
  public init(metadata: [String: Any], eventNameAbbreviation: String) {
    self.metadata = metadata
    self.eventNameAbbreviation = eventNameAbbreviation
  }
}
