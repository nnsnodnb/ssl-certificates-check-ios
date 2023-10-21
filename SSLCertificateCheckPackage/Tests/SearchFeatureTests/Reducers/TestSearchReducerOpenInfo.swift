//
//  TestSearchReducerOpenInfo.swift
//  
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
@testable import SearchFeature
import XCTest

@MainActor
final class TestSearchReducerOpenInfo: XCTestCase {
    func testPrepareShowInfo() async throws {
        let store = TestStore(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
        }

        store.dependencies.bundle = .init(
            shortVersionString: { "1.0.0-test" }
        )

        await store.send(.openInfo) {
            $0.info = .init(version: "v1.0.0-test")
        }
    }
}
