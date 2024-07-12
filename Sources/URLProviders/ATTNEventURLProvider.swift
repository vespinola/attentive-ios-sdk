//
//  ATTNEventURLProvider.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-06-06.
//

import Foundation

protocol ATTNEventURLProviding {
  func buildUrl(for userIdentity: ATTNUserIdentity, domain: String) -> URL?
  func buildUrl(for eventRequest: ATTNEventRequest, userIdentity: ATTNUserIdentity, domain: String) -> URL?
}

struct ATTNEventURLProvider: ATTNEventURLProviding {
  private enum Constants {
    static var scheme: String { "https" }
    static var host: String { "events.attentivemobile.com" }
    static var path: String { "/e" }
  }

  func buildUrl(for userIdentity: ATTNUserIdentity, domain: String) -> URL? {
    var urlComponents = getUrlComponent()

    var queryParams = userIdentity.constructBaseQueryParams(domain: domain)
    queryParams["m"] = userIdentity.buildMetadataJson()
    queryParams["t"] = ATTNEventTypes.userIdentifierCollected

    urlComponents.queryItems = queryParams.map { .init(name: $0.key, value: $0.value) }
    return urlComponents.url
  }

  func buildUrl(for eventRequest: ATTNEventRequest, userIdentity: ATTNUserIdentity, domain: String) -> URL? {
    var urlComponents = getUrlComponent()

    var queryParams = userIdentity.constructBaseQueryParams(domain: domain)
    var combinedMetadata = userIdentity.buildBaseMetadata() as [String: Any]
    combinedMetadata.merge(eventRequest.metadata) { (current, _) in current }
    queryParams["m"] = try? ATTNJsonUtils.convertObjectToJson(combinedMetadata) ?? "{}"
    queryParams["t"] = eventRequest.eventNameAbbreviation

    if let deeplink = eventRequest.deeplink {
      queryParams["pd"] = deeplink
    }

    urlComponents.queryItems = queryParams.map { .init(name: $0.key, value: $0.value) }
    return urlComponents.url
  }
}

extension ATTNEventURLProvider {
  private func getUrlComponent() -> URLComponents {
    var urlComponent = URLComponents()
    urlComponent.scheme = Constants.scheme
    urlComponent.host = Constants.host
    urlComponent.path = Constants.path
    return urlComponent
  }
}
