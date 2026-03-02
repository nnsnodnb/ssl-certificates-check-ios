//
//  TestInfoReducerOnAppear.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/03/03.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import InfoFeature
import Testing

@MainActor
struct TestInfoReducerOnAppear {
  @Test(
    .dependencies {
      $0.consentInformation.visiblePrivacyOptionsRequirements = { true }
      $0.consentInformation.load = {}
    }
  )
  func testOnAppearVisiblePrivacyOptionsRequirementsIsTrue() async throws {
    let store = TestStore(
      initialState: InfoReducer.State(
        version: "1.0.0-test",
      ),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.onAppear) {
      $0.visiblePrivacyOptionsRequirements = true
    }
    await store.receive(\.loadConsentForm) {
      $0.isLoadingConsentForm = true
    }
    await store.receive(\.loadedConsentForm) {
      $0.isLoadingConsentForm = false
    }
  }

  @Test(
    .dependencies {
      $0.consentInformation.visiblePrivacyOptionsRequirements = { false }
    }
  )
  func testOnAppearVisiblePrivacyOptionsRequirementsIsFalse() async throws {
    let store = TestStore(
      initialState: InfoReducer.State(
        version: "1.0.0-test",
      ),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.onAppear)
  }
}
