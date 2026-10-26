//
//  TestHistoryListReducerShowPaywall.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/10/26.
//

import ComposableArchitecture
@testable import SSLCertificateCheckKit
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestHistoryListReducerShowPaywall {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: HistoryListReducer.State(),
      reducer: {
        HistoryListReducer()
      },
    )

    await store.send(.showPaywall) {
      $0.destination = .paywall(.init())
    }
  }
}
