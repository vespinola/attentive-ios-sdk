//
//  ObjcATTNSDK.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-05-27.
//

import UIKit

@objc(ObjcATTNSDK)
public final class ObjcATTNSDK: NSObject {
  private let sdk: ATTNSDK

  @objc(initWithDomain:mode:)
  public init(domain: String, mode: String) {
    self.sdk = ATTNSDK(domain: domain, mode: mode)
  }

  @objc(initWithDomain:)
  public init(domain: String) {
    self.sdk = ATTNSDK(domain: domain, mode: .production)
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

// TODO: REVISIT protection keyboard
public extension ObjcATTNSDK {
  @objc func getApi() -> ATTNAPI { sdk.api }
  @objc func getUserIdentity() -> ATTNUserIdentity { sdk.userIdentity }
}
