//
//  ATTNCreativeTriggerStatus.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-06-03.
//

import Foundation

/// Status passed to ATTNCreativeTriggerCompletionHandler when the creative is opened successfully
@objc public class ATTNCreativeTriggerStatus: NSObject {
  @objc public static let opened = "CREATIVE_TRIGGER_STATUS_OPENED"
  @objc public static let closed = "CREATIVE_TRIGGER_STATUS_CLOSED"
  @objc public static let notOpened = "CREATIVE_TRIGGER_STATUS_NOT_OPENED"
  @objc public static let notClosed = "CREATIVE_TRIGGER_STATUS_NOT_CLOSED"
}
