//
//  TestConsentReducerShowConsent.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/18.
//

import ClientDependencies
import ComposableArchitecture
@testable import ConsentFeature
import DependenciesTestSupport
import Testing

@MainActor
struct TestConsentReducerShowConsent {
    @Test(
        .dependencies {
            $0.consentInformation.requestConsent = { true }
            $0.consentInformation.load = {}
        }
    )
    func testShowConsentRequestConsentIsAvailable() async throws {
        let store = TestStore(
            initialState: ConsentReducer.State(),
            reducer: {
                ConsentReducer()
            },
        )

        await store.send(.showConsent)
        await store.receive(\.completed)
        await store.receive(\.delegate.completedConsent)
    }

    @Test(
        .dependencies {
            $0.consentInformation.requestConsent = { false }
            $0.consentInformation.load = {}
        }
    )
    func testShowConsentRequestConsentIsNotAvailable() async throws {
        let store = TestStore(
            initialState: ConsentReducer.State(),
            reducer: {
                ConsentReducer()
            },
        )

        await store.send(.showConsent)
        await store.receive(\.completed)
        await store.receive(\.delegate.completedConsent)
    }
}
