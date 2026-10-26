//
//  TestRootReducerDestination.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/22.
//

import ComposableArchitecture
@testable import SSLCertificateCheckKit
import Testing

@MainActor
struct TestRootReducerDestination {
  @Test
  func testPresentedCheckSubscriptionDelegateCompleted() async throws {
    let store = TestStore(
      initialState: RootReducer.State(
        destination: .checkSubscription(.init()),
      ),
      reducer: {
        RootReducer()
      },
    )

    await store.send(.destination(.presented(.checkSubscription(.delegate(.completed)))))
    await store.receive(\.showConsent) {
      $0.destination = .consent(.init())
    }
  }

  @Test
  func testPresentedConsentDelegateCompletedConsent() async throws {
    await withDependencies {
      $0.bundle.shortVersionString = { "1.0.0-test" }
    } operation: {
      let store = TestStore(
        initialState: RootReducer.State(
          destination: .consent(.init()),
        ),
        reducer: {
          RootReducer()
        },
      )

      await store.send(.destination(.presented(.consent(.delegate(.completedConsent))))) {
        $0.destination = .main(.init(version: "v1.0.0-test"))
      }
    }
  }
}
