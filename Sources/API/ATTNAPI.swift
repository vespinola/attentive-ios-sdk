//
//  ATTNAPI.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-05-31.
//

import Foundation

public typealias ATTNAPICallback = (Data?, URL?, URLResponse?, Error?) -> Void

final class ATTNAPI {
  private enum RequestConstants {
    static var dtagUrlFormat: String { "https://cdn.attn.tv/%@/dtag.js" }
    static var regexPattern: String { "='([a-z0-9-]+)[.]attn[.]tv'" }
  }

  private var userAgentBuilder: ATTNUserAgentBuilderProtocol = ATTNUserAgentBuilder()
  private var eventUrlProvider: ATTNEventURLProviding = ATTNEventURLProvider()

  private(set) var urlSession: URLSession
  private(set) var cachedGeoAdjustedDomain: String?

  private var domain: String

  init(domain: String) {
    self.urlSession = URLSession.build(withUserAgent: userAgentBuilder.buildUserAgent())
    self.domain = domain
    self.cachedGeoAdjustedDomain = nil
  }

  init(domain: String, urlSession: URLSession) {
    self.urlSession = urlSession
    self.domain = domain
    self.cachedGeoAdjustedDomain = nil
  }

  func send(userIdentity: ATTNUserIdentity) {
    send(userIdentity: userIdentity, callback: nil)
  }

  func send(userIdentity: ATTNUserIdentity, callback: ATTNAPICallback?) {
    getGeoAdjustedDomain(domain: domain) { [weak self] geoAdjustedDomain, error in
      if let error = error {
        NSLog("Error sending user identity: '%@'", error.localizedDescription)
        return
      }

      guard let geoAdjustedDomain = geoAdjustedDomain else { return }
      self?.sendUserIdentityInternal(userIdentity: userIdentity, domain: geoAdjustedDomain, callback: callback)
    }
  }

  func send(event: ATTNEvent, userIdentity: ATTNUserIdentity) {
    send(event: event, userIdentity: userIdentity, callback: nil)
  }

  func send(event: ATTNEvent, userIdentity: ATTNUserIdentity, callback: ATTNAPICallback?) {
    getGeoAdjustedDomain(domain: domain) { [weak self] geoAdjustedDomain, error in
      if let error = error {
        NSLog("Error sending user identity: '%@'", error.localizedDescription)
        return
      }

      guard let geoAdjustedDomain = geoAdjustedDomain else { return }
      self?.sendEventInternal(event: event, userIdentity: userIdentity, domain: geoAdjustedDomain, callback: callback)
    }
  }

  func update(domain newDomain: String) {
    domain = newDomain
    cachedGeoAdjustedDomain = nil
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
    guard let url = eventUrlProvider.buildUrl(for: request, userIdentity: userIdentity, domain: domain) else {
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

  func sendUserIdentityInternal(userIdentity: ATTNUserIdentity, domain: String, callback: ATTNAPICallback?) {
    guard let url = eventUrlProvider.buildUrl(for: userIdentity, domain: domain) else {
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
}

extension ATTNAPI {
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
    let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
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

      self?.cachedGeoAdjustedDomain = geoAdjustedDomain
      completionHandler(geoAdjustedDomain, nil)
    }

    task.resume()
  }
}
