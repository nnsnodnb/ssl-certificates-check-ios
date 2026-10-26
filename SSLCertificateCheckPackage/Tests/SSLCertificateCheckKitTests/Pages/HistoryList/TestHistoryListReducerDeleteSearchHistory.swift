//
//  TestHistoryListReducerDeleteSearchHistory.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/10/26.
//

import ComposableArchitecture
import Database
@testable import SSLCertificateCheckKit
import Testing

@MainActor
struct TestHistoryListReducerDeleteSearchHistory {
  @Test
  func testIsEmptySearchHistories() async throws {
    let store = TestStore(
      initialState: HistoryListReducer.State(
        contentState: .empty,
      ),
      reducer: {
        HistoryListReducer()
      },
    )

    await store.send(.deleteSearchHistory(.init(arrayLiteral: 0)))
  }

  @Test
  func testIsExistIndex() async throws {
    @Shared(.inMemory(.isPremiumSubscriptionIsActive))
    var isPremiumActive = true

    let searchHistory = SearchHistory(id: .init(0), domain: "example.com", x509: [.stub], createdAt: .now)

    await withDependencies {
      $0.database.fetchSearchHistroies = { [] }
      $0.database.deleteSearchHistory = { _ in }
    } operation: {
      let store = TestStore(
        initialState: HistoryListReducer.State(
          contentState: .list,
          searchHistories: .init(uniqueElements: [searchHistory]),
        ),
        reducer: {
          HistoryListReducer()
        },
      )

      await store.send(.deleteSearchHistory(.init(arrayLiteral: 0)))
      await store.receive(\.fetchSearchHistories)
      await store.receive(\.internalAction.fetchedSearchHistories, []) {
        $0.contentState = .empty
        $0.searchHistories = .init(uniqueElements: [])
      }
    }
  }
}
