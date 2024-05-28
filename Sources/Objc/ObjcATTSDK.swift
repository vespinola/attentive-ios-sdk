//
//  ObjcATTSDK.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-05-27.
//

import UIKit

@objc(ObjcATTSDK)
public final class ObjcATTSDK: NSObject {
  private let sdk: ATTSDK

  @objc(initWithDomain:mode:)
  public init(domain: String, mode: String) {
    self.sdk = ATTSDK(domain: domain, mode: mode)
  }

  @objc(initWithDomain:)
  public init(domain: String) {
    self.sdk = ATTSDK(domain: domain, mode: .production)
  }

  @objc(identify:)
  public func identify(userIdentifiers: NSDictionary) {
    guard let dict = userIdentifiers as? [String: String] else {
      NSLog("UserIdentifiers casting to [String: String] failed")
      return
    }
    sdk.identify(userIdentifiers: dict)
  }

  @objc(trigger:)
  public func trigger(theView view: UIView) {
    sdk.trigger(theView: view)
  }

  // TODO: REVISIT ATTNCreativeTriggerCompletionHandler
  @objc(trigger:handler:)
  public func trigger(theView view: UIView, handler: ((String) -> Void)?) {
    sdk.trigger(theView: view, handler: handler)
  }
}
