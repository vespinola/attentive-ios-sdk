//
//  ATTNPersistentStorage.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-05-29.
//

import Foundation

@objc(ATTNPersistentStorage)
public final class ATTNPersistentStorage: NSObject {
  private enum Constants {
    static var storagePrefix: String { "com.attentive.iossdk.PERSISTENT_STORAGE" }
  }

  @objc
  public convenience override init() { self.init() }

  @objc(saveObject:forKey:)
  public func save(_ value: NSObject, forKey key: String) {
    UserDefaults.standard.setValue(value, forKey: getPrefixedKey(key))
  }

  @objc
  public func readString(forKey key: String) -> String? {
    UserDefaults.standard.string(forKey: getPrefixedKey(key))
  }

  @objc(deleteObjectForKey:)
  public func delete(forKey key: String) {
    UserDefaults.standard.removeObject(forKey: getPrefixedKey(key))
  }
}

fileprivate extension ATTNPersistentStorage {
  func getPrefixedKey(_ key: String) -> String {
    .init(format: "%@:%@", Constants.storagePrefix, key)
  }
}
