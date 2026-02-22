//
//  TestRootReducerShowCheckSubscription.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/22.
//

@testable import Application
import ComposableArchitecture
import Testing

@MainActor
struct TestRootReducerShowCheckSubscription {
    @Test
    func testIt() async throws {
        let store = TestStore(
            initialState: RootReducer.State(
                requestStartRewardAdUnitID: "ca-app-pub-3417597686353524/1636683434",
                searchPageBottomBannerAdUnitID: "ca-app-pub-3417597686353524/1523645555",
            ),
            reducer: {
                RootReducer()
            },
        )

        await store.send(.showCheckSubscription) {
            $0.checkSubscription = .init()
        }
    }
}
