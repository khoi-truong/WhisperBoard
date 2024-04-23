//
//  CancellableBag.swift
//
//  Created by Khoi Truong on 29/3/24.
//

import Combine

public class CancellableBag {
  fileprivate var cancellables = Set<AnyCancellable>()

  public init() {}

  deinit {
    cancel()
  }

  public func insert(_ cancellable: AnyCancellable) {
    cancellables.insert(cancellable)
  }

  public func cancel() {
    cancellables.forEach { $0.cancel() }
  }
}

public extension AnyCancellable {

  func store(in cancellableBag: CancellableBag) {
    store(in: &cancellableBag.cancellables)
  }
}
