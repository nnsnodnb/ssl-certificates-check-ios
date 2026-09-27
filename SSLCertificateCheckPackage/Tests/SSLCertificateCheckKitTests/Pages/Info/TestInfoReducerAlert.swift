//
//  TestInfoReducerAlert.swift
//
//
//  Created by Yuya Oka on 2023/10/15.
//

import ComposableArchitecture
import DependenciesTestSupport
import Foundation
@testable import SSLCertificateCheckKit
import Testing

@MainActor
@Suite(
  .dependencies {
    $0.openURL = OpenURLEffect { _ in true }
  }
)
struct TestInfoReducerAlert {
  @Test
  func testAlertDismiss() async throws {
    let store = TestStore(
      initialState: InfoReducer.State(
        version: "v1.0.0-test",
        presentDestination: .alert(
          AlertState(
            title: {
              TextState("Open an external browser.")
            },
            actions: {
              ButtonState(
                role: .cancel,
                label: {
                  TextState("Cancel")
                }
              )
              ButtonState(
                action: .openURL(URL(string: "https://example.com")!),
                label: {
                  TextState("Open")
                }
              )
            }
          )
        ),
      ),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.presentDestination(.dismiss)) {
      $0.presentDestination = nil
    }
  }

  @MainActor
  func testAlertPresented() async throws {
    let url = URL(string: "https://example.com")!
    let store = TestStore(
      initialState: InfoReducer.State(
        version: "v1.0.0-test",
        url: url,
        presentDestination: .alert(
          AlertState(
            title: {
              TextState("Open an external browser.")
            },
            actions: {
              ButtonState(
                role: .cancel,
                label: {
                  TextState("Cancel")
                }
              )
              ButtonState(
                action: .openURL(url),
                label: {
                  TextState("Open")
                }
              )
            }
          )
        ),
      ),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.presentDestination(.presented(.alert(.openURL(url))))) {
      $0.presentDestination = nil
    }
    await store.receive(\.openForeignBrowser, url)
  }
}
