//
//  TestRootReducerCheckSubscription.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/22.
//

@testable import Application
import ComposableArchitecture
import Testing

@MainActor
struct TestRootReducerCheckSubscription {
    @Test
    func testDelegateCompleted() async throws {
        let store = TestStore(
            initialState: RootReducer.State(
                requestStartRewardAdUnitID: "ca-app-pub-3417597686353524/1636683434",
                searchPageBottomBannerAdUnitID: "ca-app-pub-3417597686353524/1523645555",
                checkSubscription: .init(),
            ),
            reducer: {
                RootReducer()
            },
        )

        await store.send(.checkSubscription(.delegate(.completed)))
        await store.receive(\.showConsent) {
            $0.consent = .init()
        }
    }
}
