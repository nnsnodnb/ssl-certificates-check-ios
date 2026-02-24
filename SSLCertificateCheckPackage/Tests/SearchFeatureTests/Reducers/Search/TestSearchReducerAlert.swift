//
//  TestSearchReducerAlert.swift
//
//
//  Created by Yuya Oka on 2023/10/15.
//

import ComposableArchitecture
import Foundation
@testable import SearchFeature
import Testing

@MainActor
struct TestSearchReducerAlert {
  @Test
  func testDismiss() async throws {
    let store = TestStore(
      initialState: SearchReducer.State(
        searchButtonDisabled: false,
        text: "example.com",
        searchableURL: URL(string: "https://example.com"),
        alert: AlertState(
          title: {
            TextState("Failed to obtain certificate")
          },
          actions: {
            ButtonState(
              label: {
                TextState("Close")
              }
            )
          },
          message: {
            TextState("Please check or re-run the URL.")
          }
        )
      ),
      reducer: {
        SearchReducer()
      },
    )

    await store.send(.alert(.dismiss)) {
      $0.alert = nil
    }
  }
}
