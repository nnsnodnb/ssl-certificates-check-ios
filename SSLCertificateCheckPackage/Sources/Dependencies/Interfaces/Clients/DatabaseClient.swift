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
  public var addSearchHistory: @Sendable (SearchHistory) async throws -> Void
  public var deleteSearchHistory: @Sendable (SearchHistory) async throws -> Void
}

// MARK: - DependencyKey
extension DatabaseClient: DependencyKey {
  public static let liveValue: DatabaseClient = .init(
    fetchSearchHistroies: { [] },
    addSearchHistory: { _ in },
    deleteSearchHistory: { _ in },
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
