//
//  TestSearchReducerNavigationPathChanged.swift
//
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
import Foundation
@testable import SearchFeature
import Testing
import X509Parser

@MainActor
struct TestSearchReducerNavigationPathChanged {
  @MainActor
  func testResetDestinations() async throws {
    let x509 = X509.stub
    let store = TestStore(
      initialState: SearchReducer.State(
        searchButtonDisabled: false,
        text: "example.com",
        searchableURL: URL(string: "https://example.com"),
        searchResult: .init(SearchResultReducer.State(certificates: .init(uniqueElements: [x509])), id: [x509]),
        destinations: [.searchResult]
      ),
      reducer: {
        SearchReducer()
      },
    )

    await store.send(.navigationPathChanged([])) {
      $0.destinations = []
      $0.searchResult = nil
    }
  }

  @MainActor
  func testRemoveSearchResultDetail() async throws {
    let x509 = X509.stub
    let store = TestStore(
      initialState: SearchReducer.State(
        searchButtonDisabled: false,
        text: "example.com",
        searchableURL: URL(string: "https://example.com"),
        searchResult: .init(SearchResultReducer.State(certificates: .init(uniqueElements: [x509])), id: [x509]),
        searchResultDetail: .init(SearchResultDetailReducer.State(x509: x509), id: x509),
        destinations: [.searchResult, .searchResultDetail]
      ),
      reducer: {
        SearchReducer()
      },
    )

    await store.send(.navigationPathChanged([.searchResult])) {
      $0.destinations = [.searchResult]
      $0.searchResultDetail = nil
    }
  }
}
