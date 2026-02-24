//
//  TestInfoReducerBuyMeACoffee.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/23.
//

import ClientDependencies
import ComposableArchitecture
import DependenciesTestSupport
@testable import InfoFeature
import Testing

@MainActor
struct TestInfoReducerBuyMeACoffee {
  @Test(
    .dependencies {
      $0.revenueCat.buyMeACoffee = {}
    }
  )
  func testSuccess() async throws {
    let store = TestStore(
      initialState: InfoReducer.State(version: "1.0.0-test"),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.buyMeACoffee)
    await store.receive(\.successGifted, timeout: 0) {
      $0.alert = .init(
        title: {
          TextState("Thank you for the coffee gift!")
        },
        actions: {
          ButtonState(
            action: .close,
            label: {
              TextState("Keep it up!")
            },
          )
        },
        message: {
          TextState("I will continue to do my best in development!")
        },
      )
    }
  }

  @Test(
    .dependencies {
      $0.revenueCat.buyMeACoffee = { throw RevenueCatClient.Error.userCancelled }
    }
  )
  func testUserCancelled() async throws {
    let store = TestStore(
      initialState: InfoReducer.State(version: "1.0.0-test"),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.buyMeACoffee)
  }

  @Test(arguments: [RevenueCatClient.Error.internalError, RevenueCatClient.Error.purchaseError])
  func testInternalError(error: RevenueCatClient.Error) async throws {
    await withDependencies {
      $0.revenueCat.buyMeACoffee = { throw RevenueCatClient.Error.internalError }
    } operation: {
      let store = TestStore(
        initialState: InfoReducer.State(version: "1.0.0-test"),
        reducer: {
          InfoReducer()
        },
      )

      await store.send(.buyMeACoffee)
      await store.receive(\.failureGifted, timeout: 0) {
        $0.alert = .init(
          title: {
            TextState("The purchase failed.")
          },
          actions: {
            ButtonState(
              action: .close,
              label: {
                TextState("Close")
              },
            )
          },
          message: {
            TextState("Thank you for your kindness")
          },
        )
      }
    }
  }
}
