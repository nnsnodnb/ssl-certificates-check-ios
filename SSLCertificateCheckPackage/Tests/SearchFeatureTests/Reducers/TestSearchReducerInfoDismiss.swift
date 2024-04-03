//
//  TestSearchReducerInfoDismiss.swift
//  
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
@testable import SearchFeature
import XCTest

final class TestSearchReducerInfoDismiss: XCTestCase {
    @MainActor
    func testResetInfo() async throws {
        let store = TestStore(
            initialState: SearchReducer.State(info: .init(version: "v1.0.0-test"))
        ) {
            SearchReducer()
        }

        await store.send(.info(.dismiss)) {
            $0.info = nil
        }
    }
}
