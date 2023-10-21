//
//  TestSearchReducerDismissInfo.swift
//  
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
@testable import SearchFeature
import XCTest

@MainActor
final class TestSearchReducerDismissInfo: XCTestCase {
    func testResetInfo() async throws {
        let store = TestStore(
            initialState: SearchReducer.State(info: .init(version: "v1.0.0-test"))
        ) {
            SearchReducer()
        }

        store.dependencies.bundle = .init(
            shortVersionString: { "1.0.0-test" }
        )

        await store.send(.dismissInfo) {
            $0.info = nil
        }
    }
}
