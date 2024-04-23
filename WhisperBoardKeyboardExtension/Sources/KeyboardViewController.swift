//
//  KeyboardViewController.swift
//  WhisperBoardKeyboardExtension
//
//  Created by Khoi Truong on 21/4/24.
//

import KeyboardKit
import SwiftUI

final class KeyboardViewController: KeyboardInputViewController {

  static var transcription = ""

  private lazy var actionHandler = ActionHandler(controller: self)

  override func viewDidLoad() {
    configureServices()
    configureKeyboardContext()
    super.viewDidLoad()
  }

  override func viewWillSetupKeyboard() {
    super.viewWillSetupKeyboard()

    setup { controller in
      SystemKeyboard(
        state: controller.state,
        services: controller.services,
        buttonContent: { $0.view },
        buttonView: { $0.view },
        emojiKeyboard: { $0.view },
        toolbar: { $0.view }
      )
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if !Self.transcription.isEmpty {
      textDocumentProxy.insertText(Self.transcription)
      Self.transcription = ""
    }
  }
}

private extension KeyboardViewController {

  func configureServices() {
    services.actionHandler = actionHandler
    services.layoutProvider = LayoutProvider()
  }

  func configureKeyboardContext() {
    state.keyboardContext.setLocale(.english)
    state.keyboardContext.localePresentationLocale = .current
    state.keyboardContext.spaceLongPressBehavior = .moveInputCursor
    state.feedbackContext.hapticConfiguration = .enabled
    state.feedbackContext.register(.haptic(.selection, for: .repeat, on: .whisper))
  }
}
