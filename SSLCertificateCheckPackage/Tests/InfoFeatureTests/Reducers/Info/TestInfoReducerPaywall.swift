//
//  TestInfoReducerPaywall.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/23.
//

import ComposableArchitecture
@testable import InfoFeature
import Testing

@MainActor
struct TestInfoReducerPaywall {
    @Test
    func testDismiss() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(
                version: "1.0.0-test",
                paywall: .init(),
            ),
            reducer: {
                InfoReducer()
            },
        )

        await store.send(.paywall(.dismiss)) {
            $0.paywall = nil
        }
    }
}
