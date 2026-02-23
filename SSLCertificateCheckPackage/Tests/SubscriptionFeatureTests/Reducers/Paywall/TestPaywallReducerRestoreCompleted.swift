//
//  TestPaywallReducerRestoreCompleted.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/23.
//

import ComposableArchitecture
@testable import SubscriptionFeature
import Testing

@MainActor
struct TestPaywallReducerRestoreCompleted {
    @Test
    func testIsPremiumActive() async throws {
        let store = TestStore(
            initialState: PaywallReducer.State(),
            reducer: {
                PaywallReducer()
            },
        )

        let customerInfo = StubCustomerInfo(isPremiumActive: true)
        await store.send(.restoreCompleted(customerInfo)) {
            $0.$isPremiumActive.withLock { $0 = true }
            $0.alert = .init(
                title: {
                    TextState("Your purchase has been restored.")
                },
                actions: {
                    ButtonState(
                        action: .okay,
                        label: {
                            TextState("OK")
                        },
                    )
                },
            )
        }
    }

    @Test
    func testIsNotPremiumActive() async throws {
        let store = TestStore(
            initialState: PaywallReducer.State(),
            reducer: {
                PaywallReducer()
            },
        )

        let customerInfo = StubCustomerInfo(isPremiumActive: false)
        await store.send(.restoreCompleted(customerInfo)) {
            $0.$isPremiumActive.withLock { $0 = false }
            $0.alert = .init(
                title: {
                    TextState("No valid purchases were found.")
                },
            )
        }
    }
}
