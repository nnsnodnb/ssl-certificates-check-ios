//
//  TestRootReducerShowConsent.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/18.
//

@testable import Application
import ComposableArchitecture
import Testing

@MainActor
struct TestRootReducerShowConsent {
  @Test
  func testShowConsent() async throws {
    let store = TestStore(
      initialState: RootReducer.State(
        requestStartRewardAdUnitID: "ca-app-pub-3940256099942544/1712485313",
        searchPageBottomBannerAdUnitID: "ca-app-pub-3940256099942544/2435281174",
      ),
      reducer: {
        RootReducer()
      },
    )

    await store.send(.showConsent) {
      $0.consent = .init()
    }
  }
}
