//
//  TestInfoReducerOpenPaywall.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/23.
//

import ComposableArchitecture
@testable import InfoFeature
import Testing

@MainActor
struct TestInfoReducerOpenPaywall {
    @Test
    func testIt() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test"),
            reducer: {
                InfoReducer()
            },
        )

        await store.send(.openPaywall) {
            $0.paywall = .init()
        }
    }
}
