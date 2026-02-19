//
//  TestSearchReducerPreloadRewardedAds.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/19.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import SearchFeature
import Testing

@MainActor
struct TestSearchReducerPreloadRewardedAds {
    @Test(
        .dependencies {
            $0.rewardedAd.load = {}
        }
    )
    func testIt() async throws {
        let store = TestStore(
            initialState: SearchReducer.State(
                searchButtonDisabled: false,
                text: "example.com",
            ),
            reducer: {
                SearchReducer()
            },
        )

        await store.send(.preloadRewardedAds)
    }
}
