//
//  TestInfoReducerPaywall.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/23.
//

import ComposableArchitecture
@testable import SSLCertificateCheckKit
import Testing

@MainActor
struct TestInfoReducerPaywall {
  @Test
  func testDismiss() async throws {
    let store = TestStore(
      initialState: InfoReducer.State(
        version: "1.0.0-test",
        presentDestination: .paywall(.init()),
      ),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.presentDestination(.dismiss)) {
      $0.presentDestination = nil
    }
  }
}
