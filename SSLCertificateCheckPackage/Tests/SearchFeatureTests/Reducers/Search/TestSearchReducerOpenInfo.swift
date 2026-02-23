//
//  TestSearchReducerOpenInfo.swift
//  
//
//  Created by Yuya Oka on 2023/10/22.
//

import ClientDependencies
import ComposableArchitecture
import DependenciesTestSupport
@testable import SearchFeature
import Testing

@MainActor
struct TestSearchReducerOpenInfo {
    @Test(
        .dependencies {
            $0.bundle.shortVersionString = { "1.0.0-test" }
        }
    )
    func testPrepareShowInfo() async throws {
        let store = TestStore(
            initialState: SearchReducer.State(),
            reducer: {
                SearchReducer()
            }
        )

        await store.send(.openInfo) {
            $0.info = .init(version: "v1.0.0-test")
        }
    }
}
