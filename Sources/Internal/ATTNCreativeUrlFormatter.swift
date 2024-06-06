//
//  ATTNCreativeUrlFormatter.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-05-29.
//

import Foundation

protocol ATTNCreativeUrlFormatterProtocol {
  func buildCompanyCreativeUrl(
    forDomain domain: String,
    mode: String,
    userIdentity: ATTNUserIdentity
  ) -> String
}

struct ATTNCreativeUrlFormatter: ATTNCreativeUrlFormatterProtocol {
  private enum Constants {
    static var scheme: String { "https" }
    static var host: String { "creatives.attn.tv" }
    static var path: String { "/mobile-apps/index.html" }
  }

  private let appInfo: ATTNAppInfoProtocol

  init(appInfo: ATTNAppInfoProtocol = ATTNAppInfo()) {
    self.appInfo = appInfo
  }

  func buildCompanyCreativeUrl(
    forDomain domain: String,
    mode: String,
    userIdentity: ATTNUserIdentity
  ) -> String {
    var components = URLComponents()
    components.scheme = Constants.scheme
    components.host = Constants.host
    components.path = Constants.path

    var queryItems = [
      URLQueryItem(name: "domain", value: domain)
    ]

    if mode == "debug" {
      queryItems.append(URLQueryItem(name: mode, value: "matter-trip-grass-symbol"))
    }

    queryItems.append(URLQueryItem(name: "vid", value: userIdentity.visitorId))

    if let clientUserId = userIdentity.identifiers[ATTNIdentifierType.clientUserId] as? String {
      queryItems.append(URLQueryItem(name: "cuid", value: clientUserId))
    }

    if let phone = userIdentity.identifiers[ATTNIdentifierType.phone] as? String {
      queryItems.append(URLQueryItem(name: "p", value: phone))
    }

    if let email = userIdentity.identifiers[ATTNIdentifierType.email] as? String {
      queryItems.append(URLQueryItem(name: "e", value: email))
    }

    if let klaviyoId = userIdentity.identifiers[ATTNIdentifierType.klaviyoId] as? String {
      queryItems.append(URLQueryItem(name: "kid", value: klaviyoId))
    }

    if let shopifyId = userIdentity.identifiers[ATTNIdentifierType.shopifyId] as? String {
      queryItems.append(URLQueryItem(name: "sid", value: shopifyId))
    }

    if let customIdentifiersJson = getCustomIdentifiersJson(userIdentity: userIdentity) {
      queryItems.append(URLQueryItem(name: "cstm", value: customIdentifiersJson))
    }

    // Add SDK info just for analytics purposes
    queryItems.append(URLQueryItem(name: "sdkVersion", value: appInfo.getSdkVersion()))
    queryItems.append(URLQueryItem(name: "sdkName", value: appInfo.getSdkName()))

    components.queryItems = queryItems

    return components.string ?? ""
  }
}

fileprivate extension ATTNCreativeUrlFormatter {
  func getCustomIdentifiersJson(userIdentity: ATTNUserIdentity) -> String? {
    do {
      guard let customIdentifiers = userIdentity.identifiers[ATTNIdentifierType.customIdentifiers] else { return nil }
      let jsonData = try JSONSerialization.data(withJSONObject: customIdentifiers, options: [])
      return String(data: jsonData, encoding: .utf8)
    } catch {
      NSLog("ERROR: Could not parse custom identifiers to json %@", error.localizedDescription)
    }
    return "{}"
  }
}
