//
//  LayoutProvider.swift
//  WhisperBoardKeyboardExtension
//
//  Created by Khoi Truong on 22/4/24.
//

import KeyboardKit

final class LayoutProvider: KeyboardLayout.StandardProvider {

  override func keyboardLayout(for context: KeyboardContext) -> KeyboardLayout {
    let layout = super.keyboardLayout(for: context)
    layout.tryInsertWhisperButton()
    return layout
  }
}

private extension KeyboardLayout {

  func tryInsertWhisperButton() {
    guard let button = tryCreateBottomRowItem(for: .whisper) else { return }
    itemRows.insert(button, after: .space, atRow: bottomRowIndex)
  }
}
