//
//  TestInfoReducerDismiss.swift
//
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
import ConcurrencyExtras
import DependenciesTestSupport
@testable import SSLCertificateCheckKit
import Testing

@MainActor
struct TestInfoReducerDismiss {
  @Test
  func testNoneEffect() async throws {
    let calledDismiss: LockIsolated<Bool> = .init(false)

    await withDependencies {
      $0.dismiss = DismissEffect { calledDismiss.setValue(true) }
    } operation: {
      let store = TestStore(
        initialState: InfoReducer.State(version: "v1.0.0-test"),
        reducer: {
          InfoReducer()
        },
      )

      await store.send(.close)
    }

    #expect(calledDismiss.value)
  }
}
