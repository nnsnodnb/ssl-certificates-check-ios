//
//  DatabaseClient+Extensions.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/10/25.
//

import Database
import Dependencies
import DependenciesInterfaces
import Foundation
import SwiftData

public extension DatabaseClient {
  static let swiftData: Self = .init(
    fetchSearchHistroies: {
      try await Implementation.shared.fetchSearchHistories()
    },
  )
}

// MARK: - Implementation
private extension DatabaseClient {
  final actor Implementation: GlobalActor {
    // MARK: - Properties
    static let shared = Implementation()

    @Dependency(\.modelContext.make)
    private var modelContext

    // MARK: - Initialize
    private init() {
    }

    func fetchSearchHistories() throws -> [SearchHistory] {
      let context = modelContext()
      let sortBy: [SortDescriptor<SearchHistoryModel>] = [
        .init(\.createdAt, order: .reverse),
      ]
      let descriptor = FetchDescriptor<SearchHistoryModel>(predicate: nil, sortBy: sortBy)
      let models = try context.fetch(descriptor)

      let entities = models.compactMap { model in
        try? SearchHistory(
          id: model.id,
          domain: model.domain,
          x509: model.decodeX509(),
          createdAt: model.createdAt,
        )
      }
      return entities
    }
  }
}
