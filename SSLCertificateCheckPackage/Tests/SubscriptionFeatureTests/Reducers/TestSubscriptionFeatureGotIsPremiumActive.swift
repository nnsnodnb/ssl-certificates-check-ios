//
//  TestSubscriptionFeatureGotIsPremiumActive.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/21.
//

import ComposableArchitecture
import Dependencies
@testable import SubscriptionFeature
import Testing

@MainActor
struct TestSubscriptionFeatureGotIsPremiumActive { // swiftlint:disable:this type_name
    @Test
    func testAtFirst() async throws {
        let store = TestStore(
            initialState: CheckSubscriptionReducer.State(),
            reducer: {
                CheckSubscriptionReducer()
            },
        )

        await store.send(.gotIsPremiumActive(true)) {
            $0.$isPremiumActive.withLock { $0 = true }
            $0.wasSendCompleted = true
        }
        await store.receive(\.delegate.completed)
    }

    @Test
    func testAtSecond() async throws {
        let store = TestStore(
            initialState: CheckSubscriptionReducer.State(
                isPremiumActive: true,
                wasSendCompleted: true,
            ),
            reducer: {
                CheckSubscriptionReducer()
            },
        )

        await store.send(.gotIsPremiumActive(true))
    }
}
