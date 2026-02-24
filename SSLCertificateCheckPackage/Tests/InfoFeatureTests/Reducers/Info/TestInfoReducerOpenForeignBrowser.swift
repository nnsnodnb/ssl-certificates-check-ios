//
//  TestInfoReducerOpenForeignBrowser.swift
//
//
//  Created by Yuya Oka on 2023/10/22.
//

import ClientDependencies
import ComposableArchitecture
import DependenciesTestSupport
import Foundation
@testable import InfoFeature
import Testing

@MainActor
@Suite(
  .dependencies {
    $0.application.open = { _ in true }
  }
)
struct TestInfoReducerOpenForeignBrowser {
  @Test
  func testNoneEffect() async throws {
    let store = TestStore(
      initialState: InfoReducer.State(version: "v1.0.0-test"),
      reducer: {
        InfoReducer()
      },
    )

    let url = URL(string: "https://example.com")!
    await store.send(.openForeignBrowser(url))
  }
}
