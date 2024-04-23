//
//  WhisperBoardApp.swift
//  WhisperBoard
//
//  Created by Khoi Truong on 21/4/24.
//

import SwiftUI

@main
struct WhisperBoardApp: App {

  private let homeViewModel = HomeViewModel(environment: HomeEnvironment(recorder: Recorder()))

  var body: some Scene {
    WindowGroup {
      HomeView(viewModel: homeViewModel)
    }
  }
}
