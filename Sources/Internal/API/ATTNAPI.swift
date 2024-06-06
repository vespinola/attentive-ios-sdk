//
//  ATTNAPI.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-05-31.
//

import Foundation

public typealias ATTNAPICallback = (Data?, URL?, URLResponse?, Error?) -> Void

@objc(ATTNAPI)
public final class ATTNAPI: NSObject {
  private enum RequestConstants {
    static var dtagUrlFormat: String { "https://cdn.attn.tv/%@/dtag.js" }
    static var regexPattern: String { "='([a-z0-9-]+)[.]attn[.]tv'" }
  }

  private var urlSession: URLSession
  private var priceFormatter: NumberFormatter
  private var domain: String
  private var cachedGeoAdjustedDomain: String?

  // TODO REVISIT remove later
  @objc public static var userAgentBuilder: ATTNUserAgentBuilder.Type = ATTNUserAgentBuilder.self

  @objc(initWithDomain:)
  public init(domain: String) {
    self.urlSession = URLSession.build(withUserAgent: ATTNAPI.userAgentBuilder.buildUserAgent())
    self.domain = domain
    self.priceFormatter = NumberFormatter()
    self.priceFormatter.minimumFractionDigits = 2
    self.cachedGeoAdjustedDomain = nil
    super.init()
  }

  // Private initializer for testing purposes
  @objc(initWithDomain:urlSession:)
  public init(domain: String, urlSession: URLSession) {
    self.urlSession = urlSession
    self.domain = domain
    self.priceFormatter = NumberFormatter()
    self.priceFormatter.minimumFractionDigits = 2
    self.cachedGeoAdjustedDomain = nil
    super.init()
  }

  @objc(sendUserIdentity:)
  public func send(userIdentity: ATTNUserIdentity) {
    send(userIdentity: userIdentity, callback: nil)
  }

  @objc(sendUserIdentity:callback:)
  public func send(userIdentity: ATTNUserIdentity, callback: ATTNAPICallback?) {
    getGeoAdjustedDomain(domain: domain) { [weak self] geoAdjustedDomain, error in
      if let error = error {
        NSLog("Error sending user identity: '%@'", error.localizedDescription)
        return
      }

      guard let geoAdjustedDomain = geoAdjustedDomain else { return }
      self?.sendUserIdentityInternal(userIdentity: userIdentity, domain: geoAdjustedDomain, callback: callback)
    }
  }

  @objc(sendEvent:userIdentity:)
  public func send(event: ATTNEvent, userIdentity: ATTNUserIdentity) {
    send(event: event, userIdentity: userIdentity, callback: nil)
  }

  @objc(sendEvent:userIdentity:callback:)
  public func send(event: ATTNEvent, userIdentity: ATTNUserIdentity, callback: ATTNAPICallback?) {
    getGeoAdjustedDomain(domain: domain) { [weak self] geoAdjustedDomain, error in
      if let error = error {
        NSLog("Error sending user identity: '%@'", error.localizedDescription)
        return
      }

      guard let geoAdjustedDomain = geoAdjustedDomain else { return }
      self?.sendEventInternal(event: event, userIdentity: userIdentity, domain: geoAdjustedDomain, callback: callback)
    }
  }
}

fileprivate extension ATTNAPI {
  func sendEventInternal(event: ATTNEvent, userIdentity: ATTNUserIdentity, domain: String, callback: ATTNAPICallback?) {
    // Slice up the Event into individual EventRequests
    let requests = event.convertEventToRequests()

    for request in requests {
      sendEventInternalForRequest(request: request, userIdentity: userIdentity, domain: domain, callback: callback)
    }
  }

  func sendEventInternalForRequest(request: ATTNEventRequest, userIdentity: ATTNUserIdentity, domain: String, callback: ATTNAPICallback?) {
    guard let url = constructEventUrlComponents(for: request, userIdentity: userIdentity, domain: domain)?.url else {
      NSLog("Invalid URL constructed for event request.")
      return
    }

    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "POST"

    let task = urlSession.dataTask(with: urlRequest) { data, response, error in
      let message: String

      if let error = error {
        message = "Error sending for event '\(request.eventNameAbbreviation)'. Error: '\(error.localizedDescription)'"
      } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode > 400 {
        message = "Error sending the event. Incorrect status code: '\(httpResponse.statusCode)'"
      } else {
        message = "Successfully sent event of type '\(request.eventNameAbbreviation)'"
      }

      NSLog("%@", message)

      callback?(data, url, response, error)
    }

    task.resume()
  }

  func constructEventUrlComponents(for eventRequest: ATTNEventRequest, userIdentity: ATTNUserIdentity, domain: String) -> URLComponents? {
    var urlComponents = URLComponents(string: "https://events.attentivemobile.com/e")

    var queryParams = constructBaseQueryParams(userIdentity: userIdentity, domain: domain)
    var combinedMetadata = userIdentity.buildBaseMetadata() as [String: Any]
    combinedMetadata.merge(eventRequest.metadata) { (current, _) in current }
    queryParams["m"] = try? ATTNJsonUtils.convertObjectToJson(combinedMetadata) ?? "{}"
    queryParams["t"] = eventRequest.eventNameAbbreviation

    var queryItems = [URLQueryItem]()
    for (key, value) in queryParams {
      queryItems.append(URLQueryItem(name: key, value: value))
    }

    urlComponents?.queryItems = queryItems

    return urlComponents
  }

  func sendUserIdentityInternal(userIdentity: ATTNUserIdentity, domain: String, callback: ATTNAPICallback?) {
    guard let url = constructUserIdentityUrl(userIdentity: userIdentity, domain: domain)?.url else {
      NSLog("Invalid URL constructed for user identity.")
      return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    let task = urlSession.dataTask(with: request) { data, response, error in
      let message: String

      if let error = error {
        message = "Error sending user identity. Error: '\(error.localizedDescription)'"
      } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode > 400 {
        message = "Error sending the event. Incorrect status code: '\(httpResponse.statusCode)'"
      } else {
        message = "Successfully sent user identity event"
      }

      NSLog("%@", message)

      callback?(data, url, response, error)
    }

    task.resume()
  }

  static func extractDomainFromTag(_ tag: String) -> String? {
    do {
      let regex = try NSRegularExpression(pattern: RequestConstants.regexPattern, options: [])
      let matchesCount = regex.numberOfMatches(in: tag, options: [], range: NSRange(location: 0, length: tag.utf16.count))

      guard matchesCount >= 1 else {
        NSLog("No Attentive domain found in the tag")
        return nil
      }

      guard let match = regex.firstMatch(in: tag, options: [], range: NSRange(location: 0, length: tag.utf16.count)) else {
        NSLog("No Attentive domain regex match object returned.")
        return nil
      }

      let domainRange = match.range(at: 1)
      guard domainRange.location != NSNotFound, let range = Range(domainRange, in: tag) else {
        NSLog("No match found for Attentive domain in the tag.")
        return nil
      }

      let regionalizedDomain = String(tag[range])
      NSLog("Identified regionalized attentive domain: %@", regionalizedDomain)
      return regionalizedDomain
    } catch {
      NSLog("Error building the domain regex. Error: '%@'", error.localizedDescription)
      return nil
    }
  }

  func constructBaseQueryParams(userIdentity: ATTNUserIdentity, domain: String) -> [String: String] {
    var queryParams: [String: String] = [:]
    queryParams["tag"] = "modern"
    queryParams["v"] = "mobile-app"
    queryParams["c"] = domain
    queryParams["lt"] = "0"
    queryParams["evs"] = userIdentity.buildExternalVendorIdsJson()
    queryParams["u"] = userIdentity.visitorId
    return queryParams
  }
}

public extension ATTNAPI {
  @objc
  func session() -> URLSession { urlSession }

  @objc
  func getCachedGeoAdjustedDomain() -> String? { cachedGeoAdjustedDomain }

  @objc(getGeoAdjustedDomain:completionHandler:)
  func getGeoAdjustedDomain(domain: String, completionHandler: @escaping (String?, Error?) -> Void) {
    if let cachedDomain = cachedGeoAdjustedDomain {
      completionHandler(cachedDomain, nil)
      return
    }

    NSLog("Getting the geoAdjustedDomain for domain '%@'...", domain)

    let urlString = String(format: RequestConstants.dtagUrlFormat, domain)
    guard let url = URL(string: urlString) else {
      NSLog("Invalid URL format for domain '%@'", domain)
      completionHandler(nil, NSError(domain: "com.attentive.API", code: NSURLErrorBadURL, userInfo: nil))
      return
    }

    let request = URLRequest(url: url)
    let task = urlSession.dataTask(with: request) { data, response, error in
      if let error = error {
        NSLog("Error getting the geo-adjusted domain. Error: '%@'", error.localizedDescription)
        completionHandler(nil, error)
        return
      }

      guard let httpResponse = response as? HTTPURLResponse else {
        NSLog("Invalid response received.")
        completionHandler(nil, NSError(domain: "com.attentive.API", code: NSURLErrorUnknown, userInfo: nil))
        return
      }

      guard httpResponse.statusCode == 200, let data = data else {
        NSLog("Error getting the geo-adjusted domain. Incorrect status code: '%ld'", httpResponse.statusCode)
        completionHandler(nil, NSError(domain: "com.attentive.API", code: NSURLErrorBadServerResponse, userInfo: nil))
        return
      }

      let dataString = String(data: data, encoding: .utf8)
      guard let geoAdjustedDomain = ATTNAPI.extractDomainFromTag(dataString ?? "") else { return }

      if geoAdjustedDomain.isEmpty {
        let error = NSError(domain: "com.attentive.API", code: NSURLErrorBadServerResponse, userInfo: nil)
        completionHandler(nil, error)
        return
      }

      self.cachedGeoAdjustedDomain = geoAdjustedDomain
      completionHandler(geoAdjustedDomain, nil)
    }

    task.resume()
  }

  @objc
  func constructUserIdentityUrl(userIdentity: ATTNUserIdentity, domain: String) -> URLComponents? {
    var urlComponents = URLComponents(string: "https://events.attentivemobile.com/e")

    var queryParams = constructBaseQueryParams(userIdentity: userIdentity, domain: domain)
    queryParams["m"] = userIdentity.buildMetadataJson()
    queryParams["t"] = ATTNEventTypes.userIdentifierCollected

    var queryItems: [URLQueryItem] = []
    for (key, value) in queryParams {
      queryItems.append(URLQueryItem(name: key, value: value))
    }

    urlComponents?.queryItems = queryItems
    return urlComponents
  }
}
