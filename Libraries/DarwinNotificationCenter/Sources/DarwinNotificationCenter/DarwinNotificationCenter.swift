import Foundation

/// A system-wide notification center.
/// This means that all notifications will be delivered to all interested observers, regardless of the process owner.
/// Darwin notifications don't support userInfo payloads to the notifications.
/// We use FileManager to share the payload inside an AppGroup.
/// This wrapper is thread-safe.
public final class DarwinNotificationCenter {

  /// The handler type to be executed when the notification is received.
  public typealias NotificationHandler = (DarwinNotification) -> Void

  /// The shared DarwinNotificationCenter, it will always return the same instance.
  public static var `default` = DarwinNotificationCenter(payloadManager: DarwinPayloadManager.default)

  /// The underlying CFNotificationCenter.
  private let center = CFNotificationCenterGetDarwinNotifyCenter()

  /// A serial queue to sync all observation changes onto, to make the wrapper thread-safe.
  private let queue = DispatchQueue(
    label: "com.darwin-notificationcenter",
    qos: .default,
    autoreleaseFrequency: .workItem
  )

  private var handlers = [DarwinNotification.Name : NotificationHandler]()

  private let payloadManager: DarwinPayloadManagerType

  private init(payloadManager: DarwinPayloadManagerType) {
    self.payloadManager = payloadManager
  }

  // MARK: -

  /// Adds an observer to watch for the given Darwin notification, using a given completion.
  ///
  /// - Parameters:
  ///   - name: The notification name of interest.
  ///   - completion: The handler to be executed when the notification is received. This will always be executed on a dedicated userinteractive queue, so NOT the main queue. If you want, you can dispatch to the main queue yourself.
  public func addObserver(
    for name: DarwinNotification.Name,
    using completion: @escaping NotificationHandler
  ) {
    self.queue.async {
      self.handlers[name] = completion

      CFNotificationCenterAddObserver(
        self.center,
        Unmanaged.passRetained(self).toOpaque(),
        self.notificationHandler,
        name.cfString,
        nil,
        .coalesce
      )
    }
  }

  /// Remove observer for a given notification name.
  ///
  /// - Parameters:
  ///   - name: The notification name that is not interesting anymore.
  public func removeObserver(for name: DarwinNotification.Name) {
    self.queue.async {
      self.handlers[name] = nil
      do {
        try self.payloadManager.removePayload(withName: name.rawName, appGroup: name.appGroup)
      } catch {
        print(error)
      }
    }
  }

  public func post(_ notification: DarwinNotification) {
    self.queue.async {
      let name = notification.name
      do {
        try self.payloadManager.createPayload(
          notification.payload,
          withName: name.rawName,
          appGroup: name.appGroup
        )
        CFNotificationCenterPostNotification(
          self.center,
          CFNotificationName(name.cfString),
          nil,
          nil,
          false
        )
      } catch {
        print(error)
      }
    }
  }
}

extension DarwinNotificationCenter {

  // This is the actual callback when we register a notification
  private var notificationHandler: CFNotificationCallback {
    return { (_, observer, notificationName, _, _) in
      guard
        let rawValue = notificationName?.rawValue as String?,
        let name = DarwinNotification.Name(rawValue),
        let observer = observer
      else { return }

      let observedSelf = Unmanaged<DarwinNotificationCenter>.fromOpaque(observer).takeUnretainedValue()
      guard
        let handler = observedSelf.handlers[name],
        let payload = try? observedSelf.payloadManager.payload(withName: name.rawName, appGroup: name.appGroup)
      else { return }
      let notification = DarwinNotification(name, payload: payload)
      handler(notification)
    }
  }
}
