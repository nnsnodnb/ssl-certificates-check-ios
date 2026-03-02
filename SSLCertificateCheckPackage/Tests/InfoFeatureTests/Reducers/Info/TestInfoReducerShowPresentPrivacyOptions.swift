//
//  TestInfoReducerShowPresentPrivacyOptions.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/03/03.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import InfoFeature
import Testing

@MainActor
struct TestInfoReducerShowPresentPrivacyOptions {
  @Test(
    .dependencies {
      $0.consentInformation.presentPrivacyOptions = {}
    }
  )
  func testShowPresentPrivacyOptionsIsLoadingConsentForm() async {
    let store = TestStore(
      initialState: InfoReducer.State(
        version: "1.0.0-test",
        visiblePrivacyOptionsRequirements: true,
        isLoadingConsentForm: true,
      ),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.showPresentPrivacyOptions)
  }

  @Test(
    .dependencies {
      $0.consentInformation.load = {}
      $0.consentInformation.presentPrivacyOptions = {}
    }
  )
  func testShowPresentPrivacyOptionsIsNotLoadingConsentForm() async {
    let store = TestStore(
      initialState: InfoReducer.State(
        version: "1.0.0-test",
        visiblePrivacyOptionsRequirements: true,
        isLoadingConsentForm: false,
      ),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.showPresentPrivacyOptions)
    await store.receive(\.loadConsentForm) {
      $0.isLoadingConsentForm = true
    }
    await store.receive(\.loadedConsentForm) {
      $0.isLoadingConsentForm = false
    }
  }
}
