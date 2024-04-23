//
//  DarwinPayloadManager.swift
//
//
//  Created by Khoi Truong on 23/4/24.
//

import Foundation

protocol DarwinPayloadManagerType {
  func createPayload(_ payload: String, withName name: String, appGroup: String) throws
  func removePayload(withName name: String, appGroup: String) throws
  func payload(withName name: String, appGroup: String) throws -> String
}

final class DarwinPayloadManager: DarwinPayloadManagerType {

  static let `default` = DarwinPayloadManager()

  init() {}

  func createPayload(_ payload: String, withName name: String, appGroup: String) throws {
    let payloadFile = try payloadPath(withName: name, appGroup: appGroup)
    try payload.write(to: payloadFile, atomically: true, encoding: .utf8)
  }

  func removePayload(withName name: String, appGroup: String) throws {
    let payloadURL = try payloadPath(withName: name, appGroup: appGroup)
    if FileManager.default.fileExists(atPath: payloadURL.absoluteString) {
    try FileManager.default.removeItem(at: payloadURL)
    }
  }

  func payload(withName name: String, appGroup: String) throws -> String {
    let payloadURL = try payloadPath(withName: name, appGroup: appGroup)
    let payload = try String(contentsOfFile: payloadURL.path, encoding: .utf8)
    return payload
  }
}

extension DarwinPayloadManager {

  private func payloadPath(withName name: String, appGroup: String) throws -> URL {
    guard let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
      throw NSError(domain: "DarwinPayloadManager", code: 404)
    }
    guard let fileURL = URL(string: appGroupURL.absoluteString.appending(name)) else {
      throw NSError(domain: "DarwinPayloadManager", code: 405)
    }
    return fileURL.standardizedFileURL
  }
}
