//
//  ATTNParameterValidation.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-05-29.
//

import Foundation

struct ATTNParameterValidation {
  static func isNotNil(_ inputValue: NSObject?) -> Bool {
    !isNil(inputValue)
  }

  static func isStringAndNotEmpty(_ inputValue: NSObject?) -> Bool {
    !((inputValue as? String)?.isEmpty ?? true)
  }

  static func verifyNotNil(_ inputValue: NSObject?, inputName: String) {
    guard isNil(inputValue) else { return }
    NSLog("Input was nil; %@ should be non-nil", inputName)
  }

  static func verifyStringOrNil(_ inputValue: NSObject?, inputName: String) {
    guard isNil(inputValue) else { return }
    guard !isString(inputValue) || isEmpty(inputName) else { return }
    NSLog("Identifier %@ should be a non-empty NSString", inputName)
  }

  static func verify1DStringDictionaryOrNil(_ inputValue: NSDictionary?, inputName: String) {
    guard isNil(inputValue), let inputValue = inputValue else { return }

    for (key, value) in inputValue {
      verifyStringOrNil(
        value as? NSObject,
        inputName: String(format: "%@[%@]", inputName, key as? String ?? ""))
    }
  }
}

fileprivate extension ATTNParameterValidation {
  static func isNil(_ inputValue: NSObject?) -> Bool {
    inputValue == nil || (inputValue is NSNull)
  }

  static func isString(_ inputValue: NSObject?) -> Bool {
    inputValue is String || inputValue is NSString
  }

  static func isEmpty(_ inputValue: String?) -> Bool {
    inputValue?.isEmpty ?? true
  }
}
