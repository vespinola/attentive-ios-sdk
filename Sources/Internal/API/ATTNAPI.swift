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

  private enum EventTypes {
    static var purchase: String { "p" }
    static var addToCart: String { "c" }
    static var productView: String { "d" }
    static var orderConfirmed: String { "oc" }
    static var userIdentifierCollected: String { "idn" }
    static var info: String { "i" }
    static var customEvent: String { "ce" }
  }

  private enum ExternalVendorTypes {
    static var shopify: String { "0" }
    static var klaviyo: String { "1" }
    static var clientUser: String { "2" }
    static var customUser: String { "6" }
  }

  private var urlSession: URLSession
  private var priceFormatter: NumberFormatter
  private var domain: String
  private var cachedGeoAdjustedDomain: String?

  // TODO REVISIT remove later
  @objc public static var userAgentBuilder: ATTNUserAgentBuilder.Type = ATTNUserAgentBuilder.self

  @objc(initWithDomain:)
  public init(domain: String) {
    self.urlSession = ATTNAPI.buildUrlSession()
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
    let requests = convertEventToRequests(event: event)

    for request in requests {
      sendEventInternalForRequest(request: request, userIdentity: userIdentity, domain: domain, callback: callback)
    }
  }

  func convertEventToRequests(event: ATTNEvent) -> [EventRequest] {
    var eventRequests = [EventRequest]()

    if let purchase = event as? ATTNPurchaseEvent {
      if purchase.items.isEmpty {
        NSLog("No items found in the purchase event.")
        return []
      }

      var cartTotal = NSDecimalNumber.zero
      for item in purchase.items {
        var metadata = [String: Any]()
        addProductDataToDictionary(item: item, dictionary: &metadata)

        metadata["orderId"] = purchase.order.orderId

        if let cart = purchase.cart {
          metadata.addEntryIfNotNil(key: "cartId", value: cart.cartId)
          metadata.addEntryIfNotNil(key: "cartCoupon", value: cart.cartCoupon)
        }

        eventRequests.append(EventRequest(metadata: metadata, eventNameAbbreviation: EventTypes.purchase))

        cartTotal = cartTotal.adding(item.price.price)
      }

      let cartTotalString = priceFormatter.string(from: cartTotal)
      for eventRequest in eventRequests {
        eventRequest.metadata["cartTotal"] = cartTotalString
      }

      var orderConfirmedMetadata = [String: Any]()
      orderConfirmedMetadata["orderId"] = purchase.order.orderId
      orderConfirmedMetadata["cartTotal"] = cartTotalString
      orderConfirmedMetadata["currency"] = purchase.items.first?.price.currency

      var products = [[String: Any]]()
      for item in purchase.items {
        var product = [String: Any]()
        addProductDataToDictionary(item: item, dictionary: &product)
        products.append(product)
      }
      orderConfirmedMetadata["products"] = convertObjectToJson(products, defaultValue: "[]")
      eventRequests.append(EventRequest(metadata: orderConfirmedMetadata, eventNameAbbreviation: EventTypes.orderConfirmed))

      return eventRequests
    } else if let addToCart = event as? ATTNAddToCartEvent {
      if addToCart.items.isEmpty {
        NSLog("No items found in the AddToCart event.")
        return []
      }

      for item in addToCart.items {
        var metadata = [String: Any]()
        addProductDataToDictionary(item: item, dictionary: &metadata)
        eventRequests.append(EventRequest(metadata: metadata, eventNameAbbreviation: EventTypes.addToCart))
      }

      return eventRequests
    } else if let productView = event as? ATTNProductViewEvent {
      if productView.items.isEmpty {
        NSLog("No items found in the ProductView event.")
        return []
      }

      for item in productView.items {
        var metadata = [String: Any]()
        addProductDataToDictionary(item: item, dictionary: &metadata)
        eventRequests.append(EventRequest(metadata: metadata, eventNameAbbreviation: EventTypes.productView))
      }

      return eventRequests
    } else if event is ATTNInfoEvent {
      eventRequests.append(EventRequest(metadata: [String: Any](), eventNameAbbreviation: EventTypes.info))
      return eventRequests
    } else if let customEvent = event as? ATTNCustomEvent {
      var customEventMetadata = [String: Any]()
      customEventMetadata["type"] = customEvent.type
      customEventMetadata["properties"] = convertObjectToJson(customEvent.properties, defaultValue: "{}")

      eventRequests.append(EventRequest(metadata: customEventMetadata, eventNameAbbreviation: EventTypes.customEvent))
      return eventRequests

    } else {
      NSLog("ERROR: Unknown event type: \(type(of: event))")
      return []
    }
  }

  func sendEventInternalForRequest(request: EventRequest, userIdentity: ATTNUserIdentity, domain: String, callback: ATTNAPICallback?) {
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

  func addProductDataToDictionary(item: ATTNItem, dictionary: inout [String: Any]) {
    dictionary["productId"] = item.productId
    dictionary["subProductId"] = item.productVariantId
    dictionary["price"] = priceFormatter.string(from: item.price.price)
    dictionary["currency"] = item.price.currency
    dictionary["quantity"] = "\(item.quantity)"

    if let category = item.category {
      dictionary["category"] = category
    }

    if let image = item.productImage {
      dictionary["image"] = image
    }

    if let name = item.name {
      dictionary["name"] = name
    }
  }

  func constructEventUrlComponents(for eventRequest: EventRequest, userIdentity: ATTNUserIdentity, domain: String) -> URLComponents? {
    var urlComponents = URLComponents(string: "https://events.attentivemobile.com/e")

    var queryParams = constructBaseQueryParams(userIdentity: userIdentity, domain: domain)
    var combinedMetadata = buildBaseMetadata(userIdentity: userIdentity) as [String: Any]
    combinedMetadata.merge(eventRequest.metadata) { (current, _) in current }
    queryParams["m"] = convertObjectToJson(combinedMetadata, defaultValue: "{}")
    queryParams["t"] = eventRequest.eventNameAbbreviation

    var queryItems = [URLQueryItem]()
    for (key, value) in queryParams {
      queryItems.append(URLQueryItem(name: key, value: value))
    }

    urlComponents?.queryItems = queryItems

    return urlComponents
  }

  static func buildUrlSession() -> URLSession {
    let configWithUserAgent = URLSessionConfiguration.default
    let additionalHeadersWithUserAgent = ["User-Agent": userAgentBuilder.buildUserAgent()]
    configWithUserAgent.httpAdditionalHeaders = additionalHeadersWithUserAgent

    return URLSession(configuration: configWithUserAgent)
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
    queryParams["evs"] = buildExternalVendorIdsJson(userIdentity: userIdentity)
    queryParams["u"] = userIdentity.visitorId
    return queryParams
  }

  private func buildExternalVendorIdsJson(userIdentity: ATTNUserIdentity) -> String {
    var ids: [[String: String]] = []

    if let clientId = userIdentity.identifiers[ATTNIdentifierType.clientUserId] as? String {
      ids.append(["vendor": ExternalVendorTypes.clientUser, "id": clientId])
    }
    if let klaviyoId = userIdentity.identifiers[ATTNIdentifierType.klaviyoId] as? String {
      ids.append(["vendor": ExternalVendorTypes.klaviyo, "id": klaviyoId])
    }
    if let shopifyId = userIdentity.identifiers[ATTNIdentifierType.shopifyId] as? String {
      ids.append(["vendor": ExternalVendorTypes.shopify, "id": shopifyId])
    }
    if let customIdentifiers = userIdentity.identifiers[ATTNIdentifierType.customIdentifiers] as? [String: String] {
      for (key, value) in customIdentifiers {
        ids.append(["vendor": ExternalVendorTypes.customUser, "id": value, "name": key])
      }
    }

    do {
      let jsonData = try JSONSerialization.data(withJSONObject: ids, options: [])
      return String(data: jsonData, encoding: .utf8) ?? "[]"
    } catch {
      NSLog("Could not serialize the external vendor ids. Returning an empty array. Error: '\(error.localizedDescription)'")
      return "[]"
    }
  }

  func buildBaseMetadata(userIdentity: ATTNUserIdentity) -> [String: String] {
    var metadata: [String: String] = [:]
    metadata["source"] = "msdk"

    if let phone = userIdentity.identifiers[ATTNIdentifierType.phone] as? String {
      metadata["phone"] = phone
    }

    if let email = userIdentity.identifiers[ATTNIdentifierType.email] as? String {
      metadata["email"] = email
    }

    return metadata
  }

  func convertObjectToJson(_ object: Any, defaultValue: String) -> String {
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: object, options: [])
      if let jsonString = String(data: jsonData, encoding: .utf8) {
        return jsonString
      } else {
        NSLog("Could not encode JSON data to a string.")
        return defaultValue
      }
    } catch {
      NSLog("Could not serialize the object to JSON. Error: '\(error.localizedDescription)'")
      return defaultValue
    }
  }

  func buildMetadataJson(userIdentity: ATTNUserIdentity) -> String {
    let metadata = buildBaseMetadata(userIdentity: userIdentity)

    do {
      let jsonData = try JSONSerialization.data(withJSONObject: metadata, options: [])
      return String(data: jsonData, encoding: .utf8) ?? "{}"
    } catch {
      NSLog("Could not serialize the external vendor ids. Returning an empty blob. Error: '\(error.localizedDescription)'")
      return "{}"
    }
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
    queryParams["m"] = buildMetadataJson(userIdentity: userIdentity)
    queryParams["t"] = EventTypes.userIdentifierCollected

    var queryItems: [URLQueryItem] = []
    for (key, value) in queryParams {
      queryItems.append(URLQueryItem(name: key, value: value))
    }

    urlComponents?.queryItems = queryItems
    return urlComponents
  }
}
