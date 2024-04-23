//
//  ContentView.swift
//  WhisperBoard
//
//  Created by Khoi Truong on 21/4/24.
//

import SwiftUI

struct HomeView: View {

  @StateObject var viewModel: HomeViewModel

  init(viewModel: HomeViewModel) {
    self._viewModel = StateObject(wrappedValue: viewModel)
  }

  var body: some View {
    NavigationStack {
      VStack(alignment: .center, spacing: 0) {
        Button("Open System Settings", action: viewModel.onTapKeyboardSettings.accept)
          .buttonStyle(.bordered)
        Text("You must enable the keyboard in System Settings, then select it with 🌐 when typing.")
          .font(.footnote)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
          .padding(.all, 16)
        VStack(alignment: .leading, spacing: 0) {
          if !viewModel.transcription.isEmpty {
            Text(viewModel.transcription)
              .font(.body)
              .multilineTextAlignment(.leading)
              .lineLimit(nil)
              .padding(.all, 16)
          }
          Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 64, maxHeight: 108, alignment: .topLeading)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.black.opacity(0.1)))
        .padding(.all, 16)
        Spacer()
        if viewModel.isRecording {
          VStack(alignment: .center, spacing: 8) {
            Text("Recording voice...\nPlease tap on Stop button when you finish your speech.")
              .font(.footnote)
              .foregroundStyle(.secondary)
              .multilineTextAlignment(.center)
            Button("Stop", action: viewModel.onTapStop.accept)
              .buttonStyle(.borderedProminent)
          }
        }
        if viewModel.isTranscribing || viewModel.isLoadingModel {
          HStack(spacing: 8) {
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle())
            Text(viewModel.isLoadingModel ? "Loading model..." : "Transcribing...")
              .font(.body)
              .foregroundStyle(.secondary)
          }
        }
        if !viewModel.transcription.isEmpty {
          Button("Send", action: viewModel.onTapSend.accept)
            .buttonStyle(.borderedProminent)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .safeAreaPadding(.vertical)
      .navigationTitle("WhisperBoard")
      .padding()
    }
    .onOpenURL(perform: viewModel.onOpenURL.accept)
  }
}
