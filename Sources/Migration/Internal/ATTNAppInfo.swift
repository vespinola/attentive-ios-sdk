//
//  ATTNAppInfo.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-05-31.
//

import Foundation
import UIKit

@objc(ATTNAppInfo)
open class ATTNAppInfo: NSObject {
  @objc(getAppBuild)
  open class func getAppBuild() -> String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
  }

  @objc(getAppVersion)
  open class func getAppVersion() -> String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
  }

  @objc(getAppName)
  open class func getAppName() -> String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
  }

  @objc(getAppId)
  open class func getAppId() -> String {
    Bundle.main.bundleIdentifier ?? ""
  }

  @objc(getDeviceModelName)
  open class func getDeviceModelName() -> String {
    UIDevice.current.model
  }

  @objc(getDevicePlatform)
  open class func getDevicePlatform() -> String {
    UIDevice.current.systemName
  }

  @objc(getDeviceOsVersion)
  open class func getDeviceOsVersion() -> String {
    ProcessInfo.processInfo.operatingSystemVersionString
  }

  @objc(getSdkName)
  open class func getSdkName() -> String {
    "attentive-ios-sdk"
  }

  @objc(getSdkVersion)
  open class func getSdkVersion() -> String {
    SDK_VERSION
  }
}

public extension ATTNAppInfo {
  @objc static func getFormattedAppName() -> String {
    getAppName().replacingOccurrences(of: " ", with: "-")
  }
}
