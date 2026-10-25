//
//  DatabaseClient.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/10/25.
//

import Database
import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct DatabaseClient: Sendable {
  public var fetchSearchHistroies: @Sendable () async throws -> [SearchHistory]
}

// MARK: - DependencyKey
extension DatabaseClient: DependencyKey {
  public static let liveValue: DatabaseClient = .init(
    fetchSearchHistroies: { [] },
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var database: DatabaseClient {
    get {
      self[DatabaseClient.self]
    }
    set {
      self[DatabaseClient.self] = newValue
    }
  }
}
