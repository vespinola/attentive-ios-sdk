//
//  SATTNCustomEvent.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-05-16.
//

import Foundation

@objc public class SATTNCustomEvent: NSObject, ATTNEvent {
  @objc public let type: String
  @objc public let properties: [String : String]
  
  init(type: String, properties: [String : String]) {
    self.type = type
    self.properties = properties
  }
  
  @objc public static func getInstante(type: String, properties: [String : String]) -> SATTNCustomEvent? {
    ATTNParameterValidation.verifyNotNil(type as NSObject, inputName: "type")
    ATTNParameterValidation.verifyStringOrNil(type, inputName: "type")
    
    if let invalidCharInType = SATTNCustomEvent.findInvalidCharacter(in: type) {
      print("Invalid character \(invalidCharInType) in CustomEvent type \(type)")
      return nil
    }
    
    ATTNParameterValidation.verifyNotNil(properties as NSObject, inputName: "properties")
    ATTNParameterValidation.verify1DStringDictionaryOrNil(properties, inputName: "properties")
    
    if let _ = properties.keys
      .map({ SATTNCustomEvent.findInvalidCharacterInPropertiesKey(key: $0) })
      .first(where: { $0 != nil }) {
      return nil
    }
    
    return .init(type: type, properties: properties)
  }
}

extension SATTNCustomEvent {
  @objc public static func findInvalidCharacter(in type: String) -> String? {
    let invalidCharacters = ["\"", "'", "(", ")", "{", "}", "[", "]", "\\", "|", ","]
    return findCharacter(in: type, charactersToFind: invalidCharacters)
  }

  @objc public static func findInvalidCharacterInPropertiesKey(key: String) -> String? {
    let invalidCharacters = ["\"", "{", "}", "[", "]", "\\", "|"]
    return findCharacter(in: key, charactersToFind: invalidCharacters)
  }

  @objc public static func findCharacter(in input: String, charactersToFind: [String]) -> String? {
    for character in charactersToFind {
        if input.range(of: character) != nil {
            return character
        }
    }
    return nil
  }
}
