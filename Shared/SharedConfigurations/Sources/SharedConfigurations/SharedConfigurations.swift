import Foundation

public enum SharedConfigurations {
  public static let appGroup = "group.khoi.WhisperBoard"
  public static let appURLScheme = "whisperboard"
  public static var recordDeeplink: URL { URL(string: "\(appURLScheme)://record")! }
}
