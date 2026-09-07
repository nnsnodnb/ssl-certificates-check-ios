//
//  TestSearchReducerPath.swift
//
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
import Foundation
@testable import SSLCertificateCheckKit
import Testing
import X509Parser

@MainActor
struct TestSearchReducerPath {
  @Test
  func testResetDestinations() async throws {
    let x509 = X509.stub
    var path: StackState<SearchReducer.Path.State> = .init()
    path.append(.searchResult(.init(domain: "example.com", certificates: .init(uniqueElements: [x509]))))

    let store = TestStore(
      initialState: SearchReducer.State(
        searchButtonDisabled: false,
        text: "example.com",
        searchableURL: URL(string: "https://example.com"),
        path: path,
      ),
      reducer: {
        SearchReducer()
      },
    )

    await store.send(.path(.popFrom(id: 0))) {
      $0.path = .init()
    }
  }

  @Test
  func testRemoveSearchResultDetail() async throws {
    let x509 = X509.stub
    var path: StackState<SearchReducer.Path.State> = .init()
    path.append(.searchResult(.init(domain: "example.com", certificates: .init(uniqueElements: [x509]))))
    path.append(.searchResultDetail(.init(x509: x509)))

    let store = TestStore(
      initialState: SearchReducer.State(
        searchButtonDisabled: false,
        text: "example.com",
        searchableURL: URL(string: "https://example.com"),
        path: path,
      ),
      reducer: {
        SearchReducer()
      },
    )

    await store.send(.path(.popFrom(id: 1))) {
      $0.path[id: 1] = nil
    }
  }

  @Test
  func testPathElementSearchResultDelegateGoSearchResultDetail() async throws {
    let x509 = X509.stub
    var path: StackState<SearchReducer.Path.State> = .init()
    path.append(.searchResult(.init(domain: "example.com", certificates: .init(uniqueElements: [x509]))))

    let store = TestStore(
      initialState: SearchReducer.State(
        searchButtonDisabled: false,
        text: "example.com",
        searchableURL: URL(string: "https://example.com"),
        path: path,
      ),
      reducer: {
        SearchReducer()
      },
    )

    await store.send(.path(.element(id: 0, action: .searchResult(.delegate(.goSearchResultDetail(x509)))))) {
      $0.path[id: 1] = .searchResultDetail(.init(x509: x509))
    }
  }
}
