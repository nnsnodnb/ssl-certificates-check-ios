//
//  TestSearchReducerInfoDismiss.swift
//  
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
@testable import SearchFeature
import XCTest

@MainActor
final class TestSearchReducerInfoDismiss: XCTestCase {
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
