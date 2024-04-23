//
//  DarwinNotification.swift
//
//
//  Created by Khoi Truong on 23/4/24.
//

import Foundation

/// A Darwin notification. The notification payload is shared inside the AppGroup
public struct DarwinNotification: Equatable {

  /// The Darwin notification name
  public let name: Name
  public let payload: String

  /// Initializes the notification based on the name.
  public init(_ name: Name, payload: String) {
    self.name = name
    self.payload = payload
  }

  /// Initializes the notification based on the name as String.
  public init(_ rawValue: String, appGroup: String, payload: String) {
    self.name = Name(rawName: rawValue, appGroup: appGroup)
    self.payload = payload
  }
}

extension DarwinNotification {

  /// The Darwin notification name
  public struct Name: Equatable, Hashable {

    /// The CFNotificationName's value
    let rawName: String
    let appGroup: String
  }
}

extension DarwinNotification.Name {

  public init(_ rawName: String, appGroup: String) {
    self.rawName = rawName
    self.appGroup = appGroup
  }

  init?(_ rawValue: String) {
    let components = rawValue.components(separatedBy: ".")
    guard let rawName = components.last else { return nil }
    let appGroup = String(rawValue.prefix(rawValue.count - rawName.count - 1))
    guard !appGroup.isEmpty else { return nil }

    self.rawName = rawName
    self.appGroup = appGroup
  }

  var rawValue: String { "\(appGroup).\(rawName)" }

  var cfString: CFString {
    rawValue as CFString
  }
}
