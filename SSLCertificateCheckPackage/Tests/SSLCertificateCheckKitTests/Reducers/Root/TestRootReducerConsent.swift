//
//  TestRootReducerConsent.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/18.
//

import ComposableArchitecture
@testable import SSLCertificateCheckKit
import Testing

@MainActor
struct TestRootReducerConsent {
  @Test
  func testConsentDelegateCompletedConsent() async throws {
    let store = TestStore(
      initialState: RootReducer.State(
        consent: .init(),
      ),
      reducer: {
        RootReducer()
      },
    )

    await store.send(.consent(.delegate(.completedConsent))) {
      $0.consent = nil
      $0.search = .init()
    }
  }
}
