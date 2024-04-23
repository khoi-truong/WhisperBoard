//
//  Future+Extension.swift
//
//  Created by Khoi Truong on 3/16/23.
//

import Combine
import Foundation

public extension Future where Failure == Error {

  convenience init(operation: @escaping () async throws -> Output) {
    self.init { promise in
      Task {
        do {
          let output = try await operation()
          promise(.success(output))
        } catch {
          promise(.failure(error))
        }
      }
    }
  }
}
