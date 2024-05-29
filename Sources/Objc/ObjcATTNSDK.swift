//
//  ObjcATTNSDK.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-05-27.
//

import UIKit

@objc(ObjcATTNSDK)
public final class ObjcATTNSDK: NSObject {
  private var sdk: ATTNSDK

  @objc(initWithDomain:mode:)
  public init(domain: String, mode: String) {
    self.sdk = ATTNSDK(domain: domain, mode: mode)
  }

  @objc(initWithDomain:)
  public init(domain: String) {
    self.sdk = ATTNSDK(domain: domain, mode: .production)
  }

  // TODO: Temporal till migration is done
  public init(sdk: ATTNSDK) {
    self.sdk = sdk
  }

  @objc(identify:)
  public func identify(userIdentifiers: NSDictionary) {
    guard let dict = userIdentifiers as? [String: Any] else {
      NSLog("UserIdentifiers casting to [String: Any] failed")
      return
    }
    sdk.identify(dict)
  }

  @objc(trigger:)
  public func trigger(theView view: UIView) {
    sdk.trigger(view)
  }

  // TODO: REVISIT ATTNCreativeTriggerCompletionHandler
  @objc(trigger:handler:)
  public func trigger(theView view: UIView, handler: ((String) -> Void)?) {
    sdk.trigger(view, handler: handler)
  }

  @objc(clearUser)
  public func clearUser() {
    sdk.clearUser()
  }
}

// TODO: REVISIT protection keyboard
public extension ObjcATTNSDK {
  @objc func getApi() -> ATTNAPI { sdk.api }
  @objc func getUserIdentity() -> ATTNUserIdentity { sdk.userIdentity }
}
