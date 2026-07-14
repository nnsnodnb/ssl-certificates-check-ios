//
//  TestSearchReducerShowBeforeAdsAlertIfNeeded.swift
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
struct TestSearchReducerShowBeforeAdsAlertIfNeeded {
  @Test
  func testEmptyText() async throws {
    let store = TestStore(
      initialState: SearchReducer.State(),
      reducer: {
        SearchReducer()
      },
    )

    await store.send(.showBeforeAdsAlertIfNeeded)
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

    await store.send(.showBeforeAdsAlertIfNeeded)
  }

  @Test
  func testValidTextSuccessResponseIsNotPremiumActive() async throws {
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
          isPremiumActive: false,
        ),
        reducer: {
          SearchReducer()
        },
      )

      await store.send(.showBeforeAdsAlertIfNeeded) {
        $0.alert = AlertState(
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
        )
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

      await store.send(.showBeforeAdsAlertIfNeeded)
      await store.receive(\.search, URL(string: "https://example.com")!) {
        $0.isLoading = true
      }
      await store.receive(\.searchResponse, .success([x509])) {
        $0.isLoading = false
        $0.destinations = [.searchResult]
        $0.searchResult = .init(SearchResultReducer.State(certificates: .init(uniqueElements: [x509])), id: [x509])
      }
    }
  }
}
