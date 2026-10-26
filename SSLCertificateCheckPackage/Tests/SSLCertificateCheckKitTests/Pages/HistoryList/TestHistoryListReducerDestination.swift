//
//  TestHistoryListReducerDestination.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/10/26.
//

import ComposableArchitecture
import Database
@testable import SSLCertificateCheckKit
import Testing

@MainActor
struct TestHistoryListReducerDestination {
  @Test
  func testDismissDestinationIsSearchResult() async throws {
    let searchHistory = SearchHistory(id: .init(0), domain: "example.com", x509: [.stub], createdAt: .now)

    let store = TestStore(
      initialState: HistoryListReducer.State(
        contentState: .list,
        searchHistories: .init(uniqueElements: [searchHistory]),
        selectedSearchHistoy: searchHistory,
        destination: .searchResult(.init(domain: searchHistory.domain, certificates: .init(uniqueElements: searchHistory.x509))),
      ),
      reducer: {
        HistoryListReducer()
      }
    )

    await store.send(.destination(.dismiss)) {
      $0.selectedSearchHistoy = nil
      $0.destination = nil
    }
  }

  @Test
  func testDismissDestinationIsPaywall() async throws {
    let store = TestStore(
      initialState: HistoryListReducer.State(
        contentState: .needSubscription,
        destination: .paywall(.init()),
      ),
      reducer: {
        HistoryListReducer()
      }
    )

    await store.send(.destination(.dismiss)) {
      $0.destination = nil
    }
  }
}
