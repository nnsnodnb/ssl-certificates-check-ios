//
//  TestInfoReducerOpenForeignBrowser.swift
//  
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
@testable import InfoFeature
import XCTest

@MainActor
final class TestInfoReducerOpenForeignBrowser: XCTestCase {
    func testNoneEffect() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test")
        ) {
            InfoReducer()
        }

        store.dependencies.application = .init(
            open: { _ in true }
        )

        let url = URL(string: "https://example.com")!
        await store.send(.openForeignBrowser(url))
    }
}
