//
//  ATTNAppInfoMock.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-05-31.
//

import Foundation
@testable import attentive_ios_sdk_framework

class ATTNAppInfoMock: ATTNAppInfo {
  override class func getAppBuild() -> String { "appBuildValue" }
  override class func getAppVersion() -> String { "appVersionValue" }
  override class func getAppName() -> String { "appName Value" }
  override class func getAppId() -> String { "appIdValue" }
  override class func getDeviceModelName() -> String { "deviceModelNameValue" }
  override class func getDevicePlatform() -> String { "devicePlatformValue" }
  override class func getDeviceOsVersion() -> String { "deviceOsVersionValue" }
  override class func getSdkName() -> String { "sdkNameValue" }
  override class func getSdkVersion() -> String { "sdkVersionValue" }
}
