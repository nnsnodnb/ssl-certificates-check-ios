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
        let bundle = BundleClient(
            shortVersionString: { "1.0.0-test" }
        )
        let store = TestStore(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
                .dependency(bundle)
        }

        await store.send(.openInfo) {
            $0.info = .init(version: "v1.0.0-test")
        }
    }
}
