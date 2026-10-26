//
//  TestMainReducerOnAppear.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/10/26.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import SSLCertificateCheckKit
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestMainReducerOnAppear {
  @Test
  func testIt() async throws {
    await withDependencies {
      $0.revenueCat.isPremiumActiveStream = {
        AsyncStream {
          $0.yield(true)
          $0.finish()
        }
      }
    } operation: {
      @Shared(.inMemory(.isPremiumSubscriptionIsActive))
      var isPremiumActive = false

      let store = TestStore(
        initialState: MainReducer.State(version: "1.0.0-test"),
        reducer: {
          MainReducer()
        },
      )

      await store.send(.onAppear) {
        $0.info = .init(version: "1.0.0-test")
      }
      await store.receive(\.internalAction.setIsPremiumActive) {
        $0.$isPremiumActive.withLock { $0 = true }
      }
    }
  }
}
