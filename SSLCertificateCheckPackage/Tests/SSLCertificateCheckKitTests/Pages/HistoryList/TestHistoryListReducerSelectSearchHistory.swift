//
//  TestHistoryListReducerSelectSearchHistory.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/10/26.
//

import ComposableArchitecture
import Database
@testable import SSLCertificateCheckKit
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestHistoryListReducerSelectSearchHistory {
  @Test
  func testIsNotPremiumActive() async throws {
    @Shared(.inMemory(.isPremiumSubscriptionIsActive))
    var isPremiumActive = false

    let searchHistory = SearchHistory(id: .init(0), domain: "example.com", x509: [.stub], createdAt: .now)

    let store = TestStore(
      initialState: HistoryListReducer.State(),
      reducer: {
        HistoryListReducer()
      },
    )

    await store.send(.selectSearchHistory(searchHistory))
  }

  @Test
  func testIsPremiumActiveToNotNil() async throws {
    @Shared(.inMemory(.isPremiumSubscriptionIsActive))
    var isPremiumActive = true

    let searchHistory = SearchHistory(id: .init(0), domain: "example.com", x509: [.stub], createdAt: .now)

    let store = TestStore(
      initialState: HistoryListReducer.State(),
      reducer: {
        HistoryListReducer()
      },
    )

    await store.send(.selectSearchHistory(searchHistory)) {
      $0.selectedSearchHistoy = searchHistory
      $0.destination = .searchResult(.init(domain: searchHistory.domain, certificates: .init(uniqueElements: searchHistory.x509)))
    }
  }

  @Test
  func testIsPremiumActiveToNil() async throws {
    @Shared(.inMemory(.isPremiumSubscriptionIsActive))
    var isPremiumActive = true

    let searchHistory = SearchHistory(id: .init(0), domain: "example.com", x509: [.stub], createdAt: .now)

    let store = TestStore(
      initialState: HistoryListReducer.State(
        selectedSearchHistoy: searchHistory,
      ),
      reducer: {
        HistoryListReducer()
      },
    )

    await store.send(.selectSearchHistory(nil)) {
      $0.selectedSearchHistoy = nil
      $0.destination = nil
    }
  }
}
