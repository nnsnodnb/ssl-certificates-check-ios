//
//  TestInfoReducerPushLicenseList.swift
//
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
@testable import InfoFeature
import XCTest

@MainActor
final class TestInfoReducerPushLicenseList: XCTestCase {
    func testPrepareShowLicenseList() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test")
        ) {
            InfoReducer()
        }

        await store.send(.pushLicenseList) {
            $0.licenseList = .init()
            $0.destinations = [.licenseList]
            $0.interactiveDismissDisabled = true
        }
    }
}
