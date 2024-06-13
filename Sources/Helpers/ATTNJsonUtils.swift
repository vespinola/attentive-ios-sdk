//
//  ATTNJsonUtils.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-06-03.
//

import Foundation

protocol ATTNJsonUtilsProtocol {
  static func convertObjectToJson(_ object: Any) throws -> String?
}

struct ATTNJsonUtils: ATTNJsonUtilsProtocol {
  private init() { }

  static func convertObjectToJson(_ object: Any) throws -> String? {
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: object, options: [])
      guard let jsonString = String(data: jsonData, encoding: .utf8) else {
        NSLog("Could not encode JSON data to a string.")
        return nil
      }
      return jsonString
    } catch {
      throw error
    }
  }
}
