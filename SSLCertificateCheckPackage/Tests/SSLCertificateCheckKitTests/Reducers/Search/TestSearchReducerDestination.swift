//
//  TestSearchReducerDestination.swift
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
struct TestSearchReducerDestination {
  @Test
  func testDismissInfo() async throws {
    let store = TestStore(
      initialState: SearchReducer.State(destination: .info(.init(version: "v1.0.0-test"))),
      reducer: {
        SearchReducer()
      },
    )

    await store.send(.destination(.dismiss)) {
      $0.destination = nil
    }
  }

  @Test
  func testDismissAlert() async throws {
    let store = TestStore(
      initialState: SearchReducer.State(
        searchButtonDisabled: false,
        text: "example.com",
        searchableURL: URL(string: "https://example.com"),
        destination: .alert(
          AlertState(
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
      ),
      reducer: {
        SearchReducer()
      },
    )

    await store.send(.destination(.dismiss)) {
      $0.destination = nil
    }
  }

  @Test
  func testPresentedAlertWatchIsNotPremiumActive() async throws {
    let x509 = X509.stub
    await withDependencies {
      $0.rewardedInterstitialAd.load = {}
      $0.rewardedInterstitialAd.show = { 1 }
      $0.search.fetchCertificates = { _ in [x509] }
    } operation: {
      let url = URL(string: "https://example.com")!

      let store = TestStore(
        initialState: SearchReducer.State(
          searchButtonDisabled: false,
          text: "example.com",
          searchableURL: url,
          destination: .alert(
            AlertState(
              title: {
                TextState("You can obtain the certificate data by watching an ad.")
              },
              actions: {
                ButtonState(
                  role: .cancel,
                  label: {
                    TextState("Cancel")
                  },
                )
                ButtonState(
                  action: .watch(url),
                  label: {
                    TextState("Continue")
                  },
                )
              },
            ),
          ),
          isPremiumActive: false,
        ),
        reducer: {
          SearchReducer()
        },
      )

      await store.send(.destination(.presented(.alert(.watch(url))))) {
        $0.destination = nil
      }
      await store.receive(\.search) {
        $0.isLoading = true
      }
      await store.receive(\.preloadRewardedAds)
      await store.receive(\.searchResponse, .success([x509])) {
        $0.isLoading = false
        $0.path[id: 0] = .searchResult(.init(domain: "example.com", certificates: .init(uniqueElements: [x509])))
      }
    }
  }

  @Test
  func testPresentedAlertWatchFailureResponse() async throws {
    enum Error: Swift.Error {
      case testError
    }

    await withDependencies {
      $0.rewardedInterstitialAd.load = {}
      $0.rewardedInterstitialAd.show = { 1 }
      $0.search.fetchCertificates = { _ in throw Error.testError }
    } operation: {
      let url = URL(string: "https://example.com")!

      let store = TestStore(
        initialState: SearchReducer.State(
          searchButtonDisabled: false,
          text: "example.com",
          searchableURL: url,
          destination: .alert(
            AlertState(
              title: {
                TextState("You can obtain the certificate data by watching an ad.")
              },
              actions: {
                ButtonState(
                  role: .cancel,
                  label: {
                    TextState("Cancel")
                  },
                )
                ButtonState(
                  action: .watch(url),
                  label: {
                    TextState("Continue")
                  },
                )
              },
            ),
          ),
        ),
        reducer: {
          SearchReducer()
        },
      )

      await store.send(.destination(.presented(.alert(.watch(url))))) {
        $0.destination = nil
      }
      await store.receive(\.search, url) {
        $0.isLoading = true
      }
      await store.receive(\.preloadRewardedAds)
      await store.receive(\.searchResponse, .failure(.search)) {
        $0.isLoading = false
        $0.destination = .alert(
          AlertState(
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
            },
          )
        )
      }
    }
  }
}
