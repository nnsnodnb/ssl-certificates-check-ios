//
//  TestSearchReducerTextChanged.swift
//
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
import Foundation
@testable import SearchFeature
import Testing

@MainActor
struct TestSearchReducerTextChanged {
  @Test
  func testValid() async throws {
    let store = TestStore(
      initialState: SearchReducer.State(),
      reducer: {
        SearchReducer()
      },
    )

    await store.send(.textChanged("example.c")) {
      $0.text = "example.c"
      $0.searchButtonDisabled = false
      $0.searchableURL = URL(string: "https://example.c")
    }
    await store.send(.textChanged("example.com")) {
      $0.text = "example.com"
      $0.searchButtonDisabled = false
      $0.searchableURL = URL(string: "https://example.com")
    }
  }

  @MainActor
  func testInvalid() async throws {
    let store = TestStore(
      initialState: SearchReducer.State(),
      reducer: {
        SearchReducer()
      },
    )

    await store.send(.textChanged("example")) {
      $0.text = "example"
      $0.searchButtonDisabled = true
      $0.searchableURL = nil
    }
    await store.send(.textChanged("example.")) {
      $0.text = "example."
      $0.searchButtonDisabled = true
      $0.searchableURL = nil
    }
  }
}
