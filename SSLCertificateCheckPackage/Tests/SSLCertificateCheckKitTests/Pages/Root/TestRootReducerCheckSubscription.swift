//
//  TestRootReducerCheckSubscription.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/22.
//

import ComposableArchitecture
@testable import SSLCertificateCheckKit
import Testing

@MainActor
struct TestRootReducerCheckSubscription {
  @Test
  func testDelegateCompleted() async throws {
    let store = TestStore(
      initialState: RootReducer.State(
        checkSubscription: .init(),
      ),
      reducer: {
        RootReducer()
      },
    )

    await store.send(.checkSubscription(.delegate(.completed)))
    await store.receive(\.showConsent) {
      $0.consent = .init()
    }
  }
}
