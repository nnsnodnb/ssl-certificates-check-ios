//
//  TestSearchResultReducerCopyDomain.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/11/15.
//

import ComposableArchitecture
@testable import SSLCertificateCheckKit
import Testing

@MainActor
struct TestSearchResultReducerCopyDomain {
  @Test
  func testIt() async throws {
    let domain = "example.com"

    await withDependencies {
      $0.pasteboard.setString = {
        #expect($0 == domain)
      }
    } operation: {
      let store = TestStore(
        initialState: SearchResultReducer.State(
          domain: domain,
          certificates: .init(uniqueElements: [.stub]),
        ),
        reducer: {
          SearchResultReducer()
        },
      )

      await store.send(.copyDomain)
    }
  }
}
