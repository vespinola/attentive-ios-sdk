//
//  ATTNEventTypes.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-06-03.
//

import Foundation

enum ATTNEventTypes {
  static var purchase: String { "p" }
  static var addToCart: String { "c" }
  static var productView: String { "d" }
  static var orderConfirmed: String { "oc" }
  static var userIdentifierCollected: String { "idn" }
  static var info: String { "i" }
  static var customEvent: String { "ce" }
}
