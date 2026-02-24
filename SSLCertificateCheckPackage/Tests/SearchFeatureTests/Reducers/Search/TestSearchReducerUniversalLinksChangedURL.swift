//
//  TestSearchReducerTestSearchReducerUniversalLinksChangedURL.swift
//
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
import Foundation
@testable import SearchFeature
import Testing

@MainActor
struct TestSearchReducerUniversalLinksChangedURL { // swiftlint:disable:this type_name
  @Test
  func testValidURL() async throws {
    let store = TestStore(
      initialState: SearchReducer.State(),
      reducer: {
        SearchReducer()
      },
    )

    let url = URL(string: "https://nnsnodnb.moe/ssl-certificates-check-ios?encodedURL=aHR0cHM6Ly9leGFtcGxlLmNvbQ==")!
    await store.send(.universalLinksURLChanged(url))
    await store.receive(\.textChanged, "example.com", timeout: 0) {
      $0.text = "example.com"
      $0.searchButtonDisabled = false
      $0.searchableURL = URL(string: "https://example.com")
    }
  }

  @Test
  func testValidURLWhenOpenedInfo() async throws {
    let store = TestStore(
      initialState: SearchReducer.State(info: .init(version: "v1.0.0-test")),
      reducer: {
        SearchReducer()
      },
    )

    let url = URL(string: "https://nnsnodnb.moe/ssl-certificates-check-ios?encodedURL=aHR0cHM6Ly9leGFtcGxlLmNvbQ==")!
    await store.send(.universalLinksURLChanged(url)) {
      $0.info = nil
    }
    await store.receive(\.textChanged, "example.com", timeout: 0) {
      $0.text = "example.com"
      $0.searchButtonDisabled = false
      $0.searchableURL = URL(string: "https://example.com")
    }
  }

  @Test
  func testValidURLWhenOpenedSearchResult() async throws {
    let store = TestStore(
      initialState: SearchReducer.State(destinations: [.searchResult]),
      reducer: {
        SearchReducer()
      },
    )

    let url = URL(string: "https://nnsnodnb.moe/ssl-certificates-check-ios?encodedURL=aHR0cHM6Ly9leGFtcGxlLmNvbQ==")!
    await store.send(.universalLinksURLChanged(url)) {
      $0.destinations = []
    }
    await store.receive(\.textChanged, "example.com", timeout: 0) {
      $0.text = "example.com"
      $0.searchButtonDisabled = false
      $0.searchableURL = URL(string: "https://example.com")
    }
  }

  @Test
  func testNotIncludeEncodedURLQuery() async throws {
    let store = TestStore(
      initialState: SearchReducer.State(),
      reducer: {
        SearchReducer()
      },
    )

    let url = URL(string: "https://nnsnodnb.moe/ssl-certificates-check-ios?encoded=aHR0cHM6Ly9leGFtcGxlLmNvbQ==")!
    await store.send(.universalLinksURLChanged(url))
  }

  @Test
  func testNotBase64Encoded() async throws {
    let store = TestStore(
      initialState: SearchReducer.State(),
      reducer: {
        SearchReducer()
      },
    )

    let url = URL(string: "https://nnsnodnb.moe/ssl-certificates-check-ios?encodedURL=aHR0cHM6Ly9leGFtcGxlLmNvbQ")!
    await store.send(.universalLinksURLChanged(url))
  }

  @Test
  func testInvalidScheme() async throws {
    let store = TestStore(
      initialState: SearchReducer.State(),
      reducer: {
        SearchReducer()
      },
    )

    let url = URL(string: "https://nnsnodnb.moe/ssl-certificates-check-ios?encodedURL=aHR0cDovL2V4YW1wbGUuY29t")!
    await store.send(.universalLinksURLChanged(url))
  }

  @Test
  func testHostIsNone() async throws {
    let store = TestStore(
      initialState: SearchReducer.State(),
      reducer: {
        SearchReducer()
      },
    )

    let url = URL(string: "https://nnsnodnb.moe/ssl-certificates-check-ios?encodedURL=aHR0cDovLw==")!
    await store.send(.universalLinksURLChanged(url))
  }
}
