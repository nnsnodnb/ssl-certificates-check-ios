//
//  TestPaywallReducerAlert.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/23.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import SubscriptionFeature
import Testing

@MainActor
struct TestPaywallReducerAlert {
    func testAlertOkay() async throws {
        let store = TestStore(
            initialState: PaywallReducer.State(
                alert: .init(
                    title: {
                        TextState("This is test")
                    },
                    actions: {
                        ButtonState(
                            action: .okay,
                            label: {
                                TextState("Okay")
                            },
                        )
                    },
                )
            ),
            reducer: {
                PaywallReducer()
            },
        )

        await store.send(.alert(.presented(.okay))) {
            $0.alert = nil
        }
    }
}
