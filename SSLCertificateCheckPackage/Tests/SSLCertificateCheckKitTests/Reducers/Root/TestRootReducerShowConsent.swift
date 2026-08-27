//
//  TestRootReducerShowConsent.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/18.
//

import ComposableArchitecture
@testable import SSLCertificateCheckKit
import Testing

@MainActor
struct TestRootReducerShowConsent {
  @Test
  func testShowConsent() async throws {
    let store = TestStore(
      initialState: RootReducer.State(),
      reducer: {
        RootReducer()
      },
    )

    await store.send(.showConsent) {
      $0.consent = .init()
    }
  }
}
