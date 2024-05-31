//
//  ATTNUserAgentBuilder.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-05-31.
//

import Foundation

@objc(ATTNUserAgentBuilder)
open class ATTNUserAgentBuilder: NSObject {

  @objc(buildUserAgent)
  open class func buildUserAgent() -> String {
    buildUserAgent(appInfo: ATTNAppInfo.self)
  }

  @objc
  public static func buildUserAgent(appInfo: ATTNAppInfo.Type) -> String {
    // We replace the spaces with dashes for the app name because spaces in a User-Agent represent a new "product", so app names that have spaces are harder to parse if we don't replace spaces with dashes
    String(
      format: "%@/%@.%@ (%@; %@ %@) %@/%@",
      appInfo.getFormattedAppName(),
      appInfo.getAppVersion(),
      appInfo.getAppBuild(),
      appInfo.getDeviceModelName(),
      appInfo.getDevicePlatform(),
      appInfo.getDeviceOsVersion(),
      appInfo.getSdkName(),
      appInfo.getSdkVersion()
    )
  }
}
