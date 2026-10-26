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
    addSearchHistory: { searchHistory in
      try await Implementation.shared.addSearchHistory(searchHistory)
    },
    deleteSearchHistory: { searchHistory in
      try await Implementation.shared.deleteSearchHistory(searchHistory)
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

    func addSearchHistory(_ searchHistory: SearchHistory) throws {
      let model = try SearchHistoryModel(
        id: searchHistory.id,
        domain: searchHistory.domain,
        x509: searchHistory.x509,
        createdAt: searchHistory.createdAt,
      )

      let context = modelContext()
      context.insert(model)
      try context.save()
    }

    func deleteSearchHistory(_ searchHistory: SearchHistory) throws {
      let context = modelContext()
      guard let model = try getSearchHistory(id: searchHistory.id, context: context) else { return }
      context.delete(model)
      try context.save()
    }

    private func getSearchHistory(id: UUID, context: ModelContext) throws -> SearchHistoryModel? {
      let predicate = #Predicate<SearchHistoryModel> { $0.id == id }
      let descriptor = FetchDescriptor<SearchHistoryModel>(predicate: predicate, sortBy: [])
      let model = try context.fetch(descriptor).first
      return model
    }
  }
}
