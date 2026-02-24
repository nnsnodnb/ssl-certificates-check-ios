//
//  TestSearchReducerPasteURLChanged.swift
//
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
import Foundation
@testable import SearchFeature
import Testing

@MainActor
struct TestSearchReducerPasteURLChanged {
  @Test
  func testValidScheme() async throws {
    let store = TestStore(
      initialState: SearchReducer.State(),
      reducer: {
        SearchReducer()
      },
    )

    let url = URL(string: "https://example.com")!
    await store.send(.pasteURLChanged(url))
    await store.receive(\.textChanged, "example.com", timeout: 0) {
      $0.text = "example.com"
      $0.searchButtonDisabled = false
      $0.searchableURL = URL(string: "https://example.com")!
    }
  }

  @Test
  func testValidSchemeWithPath() async throws {
    let store = TestStore(
      initialState: SearchReducer.State(),
      reducer: {
        SearchReducer()
      },
    )

    let url = URL(string: "https://example.com/hoge/foo")!
    await store.send(.pasteURLChanged(url))
    await store.receive(\.textChanged, "example.com", timeout: 0) {
      $0.text = "example.com"
      $0.searchButtonDisabled = false
      $0.searchableURL = URL(string: "https://example.com")!
    }
  }

  @Test
  func testValidSchemeWithoutHost() async throws {
    let store = TestStore(
      initialState: SearchReducer.State(),
      reducer: {
        SearchReducer()
      },
    )

    let url = URL(string: "https://")!
    await store.send(.pasteURLChanged(url))
  }

  @Test
  func testInvalidScheme() async throws {
    let store = TestStore(
      initialState: SearchReducer.State(),
      reducer: {
        SearchReducer()
      },
    )

    let url = URL(string: "http://example.com")!
    await store.send(.pasteURLChanged(url))
  }
}
