//
//  TestRootReducerShowCheckSubscription.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/22.
//

import ComposableArchitecture
@testable import SSLCertificateCheckKit
import Testing

@MainActor
struct TestRootReducerShowCheckSubscription {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: RootReducer.State(),
      reducer: {
        RootReducer()
      },
    )

    await store.send(.showCheckSubscription) {
      $0.checkSubscription = .init()
    }
  }
}
