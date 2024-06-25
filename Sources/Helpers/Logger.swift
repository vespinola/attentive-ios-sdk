//
//  Logger.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-06-25.
//

import Foundation
import os

enum Loggers {
  private static var subsystem: String { Bundle.main.bundleIdentifier ?? "com.attentive.attentive-ios-sdk-local" }

  static var network = os.Logger(subsystem: subsystem, category: "network")
  static var event = os.Logger(subsystem: subsystem, category: "event")
  static var creative = os.Logger(subsystem: subsystem, category: "creative")
}
