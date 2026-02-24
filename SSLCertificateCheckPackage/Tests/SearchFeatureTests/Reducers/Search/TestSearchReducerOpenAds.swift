//
//  TestSearchReducerOpenAds.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/18.
//

import ClientDependencies
import ComposableArchitecture
import DependenciesTestSupport
import Foundation
@testable import SearchFeature
import Testing
import X509Parser

@MainActor
struct TestSearchReducerOpenAds {
  @Test
  func testEmptyText() async throws {
    let store = TestStore(
      initialState: SearchReducer.State(),
      reducer: {
        SearchReducer()
      },
    )

    await store.send(.openAds)
  }

  @Test
  func testInvalidText() async throws {
    let store = TestStore(
      initialState: SearchReducer.State(
        searchButtonDisabled: true,
        text: "example.",
        searchableURL: nil
      ),
      reducer: {
        SearchReducer()
      },
    )

    await store.send(.openAds)
  }

  @Test
  func testValidTextSuccessResponseIsNotPremiumActive() async throws {
    let x509 = X509.stub
    await withDependencies {
      $0.rewardedAd.load = {}
      $0.rewardedAd.show = { 1 }
      $0.search.fetchCertificates = { _ in [x509] }
    } operation: {
      let store = TestStore(
        initialState: SearchReducer.State(
          searchButtonDisabled: false,
          text: "example.com",
          searchableURL: URL(string: "https://example.com"),
          isPremiumActive: false,
        ),
        reducer: {
          SearchReducer()
        },
      )

      await store.send(.openAds) {
        $0.isLoading = true
      }
      await store.receive(\.search, timeout: 0)
      await store.receive(\.preloadRewardedAds, timeout: 0)
      await store.receive(\.searchResponse, .success([x509]), timeout: 0) {
        $0.isLoading = false
        $0.destinations = [.searchResult]
        $0.searchResult = .init(SearchResultReducer.State(certificates: .init(uniqueElements: [x509])), id: [x509])
      }
    }
  }

  @Test
  func testValidTextSuccessResponseIsPremiumActive() async throws {
    let x509 = X509.stub
    await withDependencies {
      $0.search.fetchCertificates = { _ in [x509] }
    } operation: {
      @Shared(.inMemory("key_premium_subscription_is_active"))
      var isPremiumActive = true

      let store = TestStore(
        initialState: SearchReducer.State(
          searchButtonDisabled: false,
          text: "example.com",
          searchableURL: URL(string: "https://example.com"),
          isPremiumActive: true,
        ),
        reducer: {
          SearchReducer()
        },
      )

      await store.send(.openAds) {
        $0.isLoading = true
      }
      await store.receive(\.search, timeout: 0)
      await store.receive(\.searchResponse, .success([x509]), timeout: 0) {
        $0.isLoading = false
        $0.destinations = [.searchResult]
        $0.searchResult = .init(SearchResultReducer.State(certificates: .init(uniqueElements: [x509])), id: [x509])
      }
    }
  }

  @Test
  func testValidTextFailureResponse() async throws {
    enum Error: Swift.Error {
      case testError
    }

    await withDependencies {
      $0.rewardedAd.load = {}
      $0.rewardedAd.show = { 1 }
      $0.search.fetchCertificates = { _ in throw Error.testError }
    } operation: {
      let store = TestStore(
        initialState: SearchReducer.State(
          searchButtonDisabled: false,
          text: "example.com",
          searchableURL: URL(string: "https://example.com"),
        ),
        reducer: {
          SearchReducer()
        },
      )

      await store.send(.openAds) {
        $0.isLoading = true
      }
      await store.receive(\.search, timeout: 0)
      await store.receive(\.preloadRewardedAds, timeout: 0)
      await store.receive(\.searchResponse, .failure(.search), timeout: 0) {
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
