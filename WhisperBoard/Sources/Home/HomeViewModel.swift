//
//  HomeViewModel.swift
//  WhisperBoard
//
//  Created by Khoi Truong on 23/4/24.
//

import AVFoundation
import CombineExt
import CombineExtension
import DarwinNotificationCenter
import Foundation
import SharedConfigurations
import SwiftWhisper
import UIKit

final class HomeViewModel: NSObject, ObservableObject {

  @Published var isRecording = false
  @Published var isTranscribing = false
  @Published var isLoadingModel = false
  @Published var transcription = ""

  let onOpenURL = PassthroughRelay<URL>()
  let onTapKeyboardSettings = PassthroughRelay<Void>()
  let onTapStop = PassthroughRelay<Void>()
  let onDeeplinkRecordAction = PassthroughRelay<Void>()
  let onTapSend = PassthroughRelay<Void>()

  private var whisper: Whisper?
  private var recordedFile: URL? = nil
  private let environment: HomeEnvironment
  private let cancellationBag = CancellableBag()

  init(environment: HomeEnvironment) {
    self.environment = environment
    super.init()
    bind()
  }
}

private extension HomeViewModel {

  func bind() {
    onOpenURL
      .sink(receiveValue: { [weak self] url in self?.handleURL(url) })
      .store(in: cancellationBag)

    onTapStop
      .receive(on: RunLoop.main)
      .sink(receiveValue: { [weak self] in
        Task { [weak self] in
          await self?.stopRecordingAndStartTranscribing()
        }
      })
      .store(in: cancellationBag)

    onDeeplinkRecordAction
      .flatMapLatest { [unowned self] _ in self.requestRecordPermission() }
      .filter { $0 }
      .receive(on: RunLoop.main)
      .sink(receiveValue: { [weak self] _ in
        Task { [weak self] in
          await self?.startRecording()
        }
      })
      .store(in: cancellationBag)

    onTapSend
      .withLatestFrom($transcription)
      .filter { !$0.isEmpty }
      .receive(on: RunLoop.main)
      .sink(receiveValue: { [weak self] in
        self?.postTranscription($0)
      })
      .store(in: cancellationBag)

    onTapKeyboardSettings
      .receive(on: RunLoop.main)
      .sink(receiveValue: {
        guard let appSettingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(appSettingsURL, options: [:], completionHandler: nil)
      })
      .store(in: cancellationBag)
  }
}

private extension HomeViewModel {

  private func requestRecordPermission() -> AnyPublisher<Bool, Never> {
    return Deferred {
      Future<Bool, Never> { promise in
        AVAudioSession.sharedInstance().requestRecordPermission { isGranted in
          promise(.success(isGranted))
        }
      }
    }
    .eraseToAnyPublisher()
  }

  @MainActor
  func startRecording() async {
    await stopRecording()
    transcription = ""
    do {
      let documentDirectory = try FileManager.default.url(
        for: .documentDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
      )
      let file = documentDirectory.appending(path: "output.wav")
      try await environment.recorder.startRecording(toOutputFile: file, delegate: self)
      isRecording = true
      recordedFile = file
    } catch {
      isRecording = false
    }
  }

  @MainActor
  func stopRecordingAndStartTranscribing() async {
    await stopRecording()
    if let recordedFile {
      await transcribeAudio(recordedFile)
    }
  }

  func stopRecording() async {
    await environment.recorder.stopRecording()
    isRecording = false
  }

  @MainActor
  func transcribeAudio(_ url: URL) async {
    loadWhisperIfNeeded()
    guard let whisper else {
      isTranscribing = false
      return
    }
    do {
      isLoadingModel = false
      isTranscribing = true
      let audioFrames = try await AudioUtils.pcmArray(fromAudioFileURL: url)
      let segments = try await whisper.transcribe(audioFrames: audioFrames)
      transcription = segments.map(\.text).joined().trimmingCharacters(in: .whitespacesAndNewlines)
    } catch {
      print(error.localizedDescription)
      isTranscribing = false
    }
    isTranscribing = false
  }

  @MainActor
  func loadWhisperIfNeeded() {
    if whisper != nil { return }
    guard
      let modelPath = Bundle.main.url(forResource: "ggml-base", withExtension: "bin")
    else { return }
    isLoadingModel = true
    whisper = Whisper(fromFileURL: modelPath)
  }
}

extension HomeViewModel: AVAudioRecorderDelegate {

  nonisolated func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
    guard let error else { return }
    print(error.localizedDescription)
    isRecording = false
  }

  nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    isRecording = false
  }
}

private extension HomeViewModel {

  func handleURL(_ url: URL) {
    guard url.scheme == SharedConfigurations.appURLScheme else { return }
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
    guard let action = components.host.flatMap(DeeplinkAction.init) else { return }
    handleDeeplinkAction(action)
  }

  func handleDeeplinkAction(_ action: DeeplinkAction) {
    switch action {
    case .record:
      onDeeplinkRecordAction.accept(())
    }
  }

  func postTranscription(_ transcription: String) {
    DarwinNotificationCenter.default.post(
      .init(
        DarwinNotificationConfigurations.transcriptionDidFinishNotificationName,
        appGroup: SharedConfigurations.appGroup,
        payload: transcription
      )
    )
  }
}
