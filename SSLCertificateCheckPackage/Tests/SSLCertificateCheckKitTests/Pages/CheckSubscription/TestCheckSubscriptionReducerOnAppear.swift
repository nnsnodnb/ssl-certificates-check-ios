//
//  TestCheckSubscriptionReducerOnAppear.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/21.
//

import Combine
import ComposableArchitecture
import DependenciesTestSupport
@testable import SSLCertificateCheckKit
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestCheckSubscriptionReducerOnAppear {
  @Test(
    .dependencies {
      $0.revenueCat.isPremiumActive = { true }
    }
  )
  func testGetIsActive() async throws {
    let store = TestStore(
      initialState: CheckSubscriptionReducer.State(),
      reducer: {
        CheckSubscriptionReducer()
      },
    )

    await store.send(.onAppear)
    await store.receive(\.internalAction.setIsPremiumActive) {
      $0.$isPremiumActive.withLock { $0 = true }
    }
    await store.receive(\.delegate.completed)
  }
}
