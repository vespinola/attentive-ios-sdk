//
//  ATTNAppInfo.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-05-31.
//

import Foundation
import UIKit

open class ATTNAppInfo {
  open class func getAppBuild() -> String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
  }

  open class func getAppVersion() -> String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
  }

  open class func getAppName() -> String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
  }

  open class func getAppId() -> String {
    Bundle.main.bundleIdentifier ?? ""
  }

  open class func getDeviceModelName() -> String {
    UIDevice.current.model
  }

  open class func getDevicePlatform() -> String {
    UIDevice.current.systemName
  }

  open class func getDeviceOsVersion() -> String {
    ProcessInfo.processInfo.operatingSystemVersionString
  }

  open class func getSdkName() -> String {
    "attentive-ios-sdk"
  }

  open class func getSdkVersion() -> String {
    ATTNConstants.sdkVersion
  }
}

public extension ATTNAppInfo {
  static func getFormattedAppName() -> String {
    getAppName().replacingOccurrences(of: " ", with: "-")
  }
}
