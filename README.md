WhisperBoard
============

## Setup

1. Download the `ggml-base` model from [here](https://huggingface.co/ggerganov/whisper.cpp/blob/main/ggml-base.bin)
2. Copy the `ggml-base.bin` file into the `WhisperBoard/Resources/WhisperModels/` directory.
3. Run the `WhisperBoard.xcodeproj` project with the `WhisperBoard` scheme.
4. Run the `WhisperServer.xcodeproj` project with the `WhisperBoardKeyboardExtension` scheme.

## Demo

[![WhisperBoard Demo](https://img.youtube.com/vi/kGlyZouGGlI/0.jpg)](http://www.youtube.com/watch?v=kGlyZouGGlI)

## Techstack

- Architecture
  - Presentation layer: `MVVM`, `Combine`, `SwiftUI`, `Swift Concurrency`
  - Modular achitecture: `Local Swift Package`
- App extension communication: `App Groups`, `Darwin Notifications`
- Keyboard extension: `KeyboardKit`
- Whisper integration: `SwiftWhisper`
