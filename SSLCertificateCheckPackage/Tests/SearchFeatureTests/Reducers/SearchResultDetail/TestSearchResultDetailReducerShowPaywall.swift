//
//  TestSearchResultDetailReducerShowPaywall.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/23.
//

import ComposableArchitecture
@testable import SearchFeature
import Testing

@MainActor
struct TestSearchResultDetailReducerShowPaywall {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: SearchResultDetailReducer.State(x509: .stub),
      reducer: {
        SearchResultDetailReducer()
      },
    )

    await store.send(.showPaywall) {
      $0.paywall = .init()
    }
  }
}
