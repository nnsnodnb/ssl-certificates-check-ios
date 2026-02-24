//
//  TestConsentReducerCompleted.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/18.
//

import ComposableArchitecture
@testable import ConsentFeature
import DependenciesTestSupport
import Testing

@MainActor
struct TestConsentReducerCompleted {
  @Test
  func testCompleted() async throws {
    let store = TestStore(
      initialState: ConsentReducer.State(),
      reducer: {
        ConsentReducer()
      },
    )

    await store.send(.completed)
    await store.receive(\.delegate.completedConsent)
  }
}
