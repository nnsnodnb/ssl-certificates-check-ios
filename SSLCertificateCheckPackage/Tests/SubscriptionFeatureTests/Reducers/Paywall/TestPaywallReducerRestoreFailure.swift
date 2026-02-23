//
//  TestPaywallReducerRestoreFailure.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/23.
//

import ComposableArchitecture
@testable import SubscriptionFeature
import Testing

@MainActor
struct TestPaywallReducerRestoreFailure {
    @Test
    func testIt() async throws {
        let store = TestStore(
            initialState: PaywallReducer.State(),
            reducer: {
                PaywallReducer()
            },
        )

        await store.send(.restoreFailure) {
            $0.alert = .init(
                title: {
                    TextState("Failed to restore purchases.")
                },
                actions: {
                    ButtonState(
                        action: .close,
                        label: {
                            TextState("Close")
                        },
                    )
                },
            )
        }
    }
}
