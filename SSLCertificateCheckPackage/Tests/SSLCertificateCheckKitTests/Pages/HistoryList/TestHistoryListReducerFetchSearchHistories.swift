//
//  TestHistoryListReducerFetchSearchHistories.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/10/26.
//

import ComposableArchitecture
import Database
@testable import SSLCertificateCheckKit
import Testing

@MainActor
struct TestHistoryListReducerFetchSearchHistories {
  @Test
  func testIsNotPremiumActive() async throws {
    @Shared(.inMemory(.isPremiumSubscriptionIsActive))
    var isPremiumActive = false

    let store = TestStore(
      initialState: HistoryListReducer.State(),
      reducer: {
        HistoryListReducer()
      },
    )

    await store.send(.fetchSearchHistories) {
      $0.contentState = .needSubscription
    }
  }

  @Test
  func testIsPremiumActiveGotEmpty() async throws {
    await withDependencies {
      $0.database.fetchSearchHistroies = { [] }
    } operation: {
      @Shared(.inMemory(.isPremiumSubscriptionIsActive))
      var isPremiumActive = true

      let store = TestStore(
        initialState: HistoryListReducer.State(),
        reducer: {
          HistoryListReducer()
        },
      )

      await store.send(.fetchSearchHistories)
      await store.receive(\.internalAction.fetchedSearchHistories)
    }
  }

  @Test
  func testIsPremiumActiveGotExist() async throws {
    let searchHistory = SearchHistory(id: .init(0), domain: "example.com", x509: [.stub], createdAt: .now)

    await withDependencies {
      $0.database.fetchSearchHistroies = { [searchHistory] }
    } operation: {
      @Shared(.inMemory(.isPremiumSubscriptionIsActive))
      var isPremiumActive = true

      let store = TestStore(
        initialState: HistoryListReducer.State(),
        reducer: {
          HistoryListReducer()
        },
      )

      await store.send(.fetchSearchHistories)
      await store.receive(\.internalAction.fetchedSearchHistories) {
        $0.contentState = .list
        $0.searchHistories = .init(uniqueElements: [searchHistory])
      }
    }
  }
}
