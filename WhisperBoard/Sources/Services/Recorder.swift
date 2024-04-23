//
//  Recorder.swift
//  WhisperBoard
//
//  Created by Khoi Truong on 23/4/24.
//

import Foundation
import AVFoundation

protocol RecorderType: Actor {
  func startRecording(toOutputFile url: URL, delegate: AVAudioRecorderDelegate?) throws
  func stopRecording()
}

actor Recorder: RecorderType {
  private var recorder: AVAudioRecorder?

  enum RecorderError: Error {
    case couldNotStartRecording
  }

  func startRecording(toOutputFile url: URL, delegate: AVAudioRecorderDelegate?) throws {
    try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
    try AVAudioSession.sharedInstance().setActive(true)

    let recordSettings: [String : Any] = [
      AVFormatIDKey: Int(kAudioFormatLinearPCM),
      AVSampleRateKey: 16000.0,
      AVNumberOfChannelsKey: 1,
      AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    let recorder = try AVAudioRecorder(url: url, settings: recordSettings)
    recorder.delegate = delegate
    if recorder.record() == false {
      print("Could not start recording")
      throw RecorderError.couldNotStartRecording
    }
    self.recorder = recorder
  }

  func stopRecording() {
    recorder?.stop()
    recorder = nil
  }
}
