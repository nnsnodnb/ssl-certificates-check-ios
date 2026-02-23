//
//  TestSearchResultDetailReducerPaywall.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/23.
//

import ComposableArchitecture
@testable import SearchFeature
import Testing

@MainActor
struct TestSearchResultDetailReducerPaywall {
    @Test
    func testDismiss() async throws {
        let store = TestStore(
            initialState: SearchResultDetailReducer.State(
                x509: .stub,
                paywall: .init(),
            ),
            reducer: {
                SearchResultDetailReducer()
            },
        )

        await store.send(.paywall(.dismiss)) {
            $0.paywall = nil
        }
    }
}
