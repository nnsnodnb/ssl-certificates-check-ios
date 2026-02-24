//
//  TestInfoReducerNavigationPathChanged.swift
//
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
@testable import InfoFeature
import Testing

@MainActor
struct TestInfoReducerNavigationPathChanged {
  @Test
  func testAppendLicenseList() async throws {
    let store = TestStore(
      initialState: InfoReducer.State(version: "v1.0.0-test"),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.navigationPathChanged([.licenseList])) {
      $0.destinations = [.licenseList]
      $0.interactiveDismissDisabled = true
    }
  }

  @Test
  func testResetDestinations() async throws {
    let store = TestStore(
      initialState: InfoReducer.State(
        version: "v1.0.0-test",
        destinations: [.licenseList]
      ),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.navigationPathChanged([])) {
      $0.destinations = []
      $0.interactiveDismissDisabled = false
    }
  }

  @Test
  func testNoneEffect() async throws {
    let store = TestStore(
      initialState: InfoReducer.State(version: "v1.0.0-test"),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.navigationPathChanged([]))
  }
}
