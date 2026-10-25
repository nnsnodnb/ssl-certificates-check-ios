//
//  ModelContextClient.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/10/25.
//

import Database
import Dependencies
import DependenciesMacros
import Foundation
import SwiftData

@DependencyClient
public struct ModelContextClient: Sendable {
  public let make: @Sendable () -> ModelContext
}

// MARK: - DependencyKey
extension ModelContextClient: DependencyKey {
  public static let liveValue: ModelContextClient = .init(
    make: {
      do {
        let container = try ModelContainer(for: SearchHistoryModel.self)
        return ModelContext(container)
      } catch {
        fatalError("\(error)")
      }
    },
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var modelContext: ModelContextClient {
    get {
      self[ModelContextClient.self]
    }
    set {
      self[ModelContextClient.self] = newValue
    }
  }
}
