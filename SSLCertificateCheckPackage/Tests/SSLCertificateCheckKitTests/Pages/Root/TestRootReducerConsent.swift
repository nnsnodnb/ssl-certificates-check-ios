//
//  TestRootReducerConsent.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/18.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import SSLCertificateCheckKit
import Testing

@MainActor
struct TestRootReducerConsent {
  @Test
  func testConsentDelegateCompletedConsent() async throws {
    await withDependencies {
      $0.bundle.shortVersionString = { "1.0.0-test" }
    } operation: {
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
        $0.historyList = .init()
        $0.info = .init(version: "v1.0.0-test")
      }
    }
  }
}
