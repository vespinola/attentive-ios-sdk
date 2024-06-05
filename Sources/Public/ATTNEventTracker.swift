//
//  ATTNEventTracker.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-05-30.
//

import Foundation

//@objc(ATTNEventTracker)
public final class ATTNEventTracker: NSObject {
  private static var _sharedInstance: ATTNEventTracker?
  private let sdk: ATTNSDK

//  @objc(initWithSdk:)
  public init(sdk: ATTNSDK) {
    self.sdk = sdk
  }

//  @objc(setupWithSdk:)
  public static func setup(with sdk: ATTNSDK) {
    _sharedInstance = ATTNEventTracker(sdk: sdk)
  }

//  @objc(recordEvent:)
  public func record(event: ATTNEvent) {
    sdk.send(event: event)
  }

//  @objc
  public static func sharedInstance() -> ATTNEventTracker? {
    assert(_sharedInstance != nil, "ATTNEventTracker must be setup before being used")
    return _sharedInstance
  }

  static func destroy() {
    _sharedInstance = nil
  }
}
