//
//  TestInfoReducerDismiss.swift
//
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
@testable import InfoFeature
import Testing

@MainActor
struct TestInfoReducerDismiss {
  @Test
  func testNoneEffect() async throws {
    let store = TestStore(
      initialState: InfoReducer.State(version: "v1.0.0-test"),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.close)
  }
}
