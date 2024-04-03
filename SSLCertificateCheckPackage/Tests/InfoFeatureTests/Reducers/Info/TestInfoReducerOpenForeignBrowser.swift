//
//  TestInfoReducerOpenForeignBrowser.swift
//  
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
@testable import InfoFeature
import XCTest

final class TestInfoReducerOpenForeignBrowser: XCTestCase {
    @MainActor
    func testNoneEffect() async throws {
        let application = ApplicationClient(
            open: { _ in true }
        )
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test")
        ) {
            InfoReducer()
                .dependency(application)
        }

        let url = URL(string: "https://example.com")!
        await store.send(.openForeignBrowser(url))
    }
}
