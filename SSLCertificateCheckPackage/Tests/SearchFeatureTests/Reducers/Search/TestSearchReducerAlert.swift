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
import X509Parser

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

  @Test
  func testPresentedWatchIsNotPremiumActive() async throws {
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
          alert: AlertState(
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
          isPremiumActive: false,
        ),
        reducer: {
          SearchReducer()
        },
      )

      await store.send(.alert(.presented(.watch(url)))) {
        $0.alert = nil
      }
      await store.receive(\.search) {
        $0.isLoading = true
      }
      await store.receive(\.preloadRewardedAds)
      await store.receive(\.searchResponse, .success([x509])) {
        $0.isLoading = false
        $0.destinations = [.searchResult]
        $0.searchResult = .init(SearchResultReducer.State(certificates: .init(uniqueElements: [x509])), id: [x509])
      }
    }
  }

  @Test
  func testPresentedWatchFailureResponse() async throws {
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
          alert: AlertState(
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
        reducer: {
          SearchReducer()
        },
      )

      await store.send(.alert(.presented(.watch(url)))) {
        $0.alert = nil
      }
      await store.receive(\.search, url) {
        $0.isLoading = true
      }
      await store.receive(\.preloadRewardedAds)
      await store.receive(\.searchResponse, .failure(.search)) {
        $0.isLoading = false
        $0.alert = AlertState(
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
      }
    }
  }
}
