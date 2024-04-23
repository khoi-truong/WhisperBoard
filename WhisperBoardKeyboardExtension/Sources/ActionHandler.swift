//
//  WhisperActionHandler.swift
//  WhisperBoardKeyboardExtension
//
//  Created by Khoi Truong on 21/4/24.
//

import DarwinNotificationCenter
import KeyboardKit
import SharedConfigurations

final class ActionHandler: KeyboardAction.StandardHandler {

  override func action(
    for gesture: Gestures.KeyboardGesture,
    on action: KeyboardAction
  ) -> KeyboardAction.GestureAction? {
    let standard = super.action(for: gesture, on: action)
    switch gesture {
    case .press: return pressAction(for: action) ?? standard
    case .release: return releaseAction(for: action) ?? standard
    default: return standard
    }
  }
}

// MARK: - Custom actions

private extension ActionHandler {

  func pressAction(
    for action: KeyboardAction
  ) -> KeyboardAction.GestureAction? {
    return nil
  }

  func releaseAction(
    for action: KeyboardAction
  ) -> KeyboardAction.GestureAction? {
    switch action {
    case .whisper: return { [weak self] _ in self?.handleWhisperAction() }
    default: return nil
    }
  }
}

private extension ActionHandler {

  func handleWhisperAction() {
    print("WHISPER")
    DarwinNotificationCenter.default.addObserver(for: transcriptionDidFinishNotification) { notification in
      print("RECEIVED DARWIN NOTIFICATION: \(notification.payload)")
      KeyboardViewController.transcription = notification.payload
      DarwinNotificationCenter.default.removeObserver(for: transcriptionDidFinishNotification)
    }
    keyboardController?.openUrl(SharedConfigurations.recordDeeplink)
  }
}

private let transcriptionDidFinishNotification = DarwinNotification.Name(
  DarwinNotificationConfigurations.transcriptionDidFinishNotificationName,
  appGroup: SharedConfigurations.appGroup
)

