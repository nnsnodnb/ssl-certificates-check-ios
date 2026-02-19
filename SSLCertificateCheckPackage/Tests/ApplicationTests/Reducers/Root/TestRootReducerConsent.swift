//
//  TestRootReducerConsent.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/18.
//

@testable import Application
import ComposableArchitecture
import Testing

@MainActor
struct TestRootReducerConsent {
    @Test
    func testConsentDelegateCompletedConsent() async throws {
        let store = TestStore(
            initialState: RootReducer.State(
                requestStartRewardAdUnitID: "ca-app-pub-3940256099942544/1712485313",
                searchPageBottomBannerAdUnitID: "ca-app-pub-3940256099942544/2435281174",
                consent: .init(),
            ),
            reducer: {
                RootReducer()
            },
        )

        await store.send(.consent(.delegate(.completedConsent))) {
            $0.consent = nil
            $0.search = .init()
        }
    }
}
