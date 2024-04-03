//
//  TestInfoReducerNavigationPathChanged.swift
//  
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
@testable import InfoFeature
import XCTest

final class TestInfoReducerNavigationPathChanged: XCTestCase {
    @MainActor
    func testAppendLicenseList() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test")
        ) {
            InfoReducer()
        }

        await store.send(.navigationPathChanged([.licenseList])) {
            $0.destinations = [.licenseList]
            $0.interactiveDismissDisabled = true
        }
    }

    @MainActor
    func testResetDestinations() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(
                version: "v1.0.0-test",
                destinations: [.licenseList]
            )
        ) {
            InfoReducer()
        }

        await store.send(.navigationPathChanged([])) {
            $0.destinations = []
            $0.interactiveDismissDisabled = false
        }
    }

    @MainActor
    func testNoneEffect() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test")
        ) {
            InfoReducer()
        }

        await store.send(.navigationPathChanged([]))
    }
}
