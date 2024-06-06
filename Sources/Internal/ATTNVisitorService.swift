//
//  ATTNVisitorService.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-05-29.
//

import Foundation

@objc(ATTNVisitorService)
public final class ATTNVisitorService: NSObject {
  private enum Constants {
    static var visitorIdKey: String { "visitorId" }
  }

  private let persistentStorage: ATTNPersistentStorage

  @objc
  public override init() {
    self.persistentStorage = .init()
  }

  @objc
  public func getVisitorId() -> String {
    guard let existingVisitorId = persistentStorage.readString(forKey: Constants.visitorIdKey) else {
      return createNewVisitorId()
    }

    return existingVisitorId
  }

  @objc
  public func createNewVisitorId() -> String {
    let newVisitorId = generateVisitorId()
    persistentStorage.save(newVisitorId as NSObject, forKey: Constants.visitorIdKey)
    return newVisitorId
  }

}

fileprivate extension ATTNVisitorService {
  func generateVisitorId() -> String {
    UUID()
      .uuidString
      .replacingOccurrences(of: "-", with: "")
  }
}
