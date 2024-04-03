//
//  TestInfoReducerURL.swift
//  
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
import Foundation
@testable import InfoFeature
import XCTest

final class TestInfoReducerURL: XCTestCase {
    @MainActor
    func testCaseURL() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test")
        ) {
            InfoReducer()
        }

        await store.send(.url(URL(string: "https://github.com/nnsnodnb/ssl-certificates-check-ios")))
    }

    @MainActor
    func testCaseSafari() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test")
        ) {
            InfoReducer()
        }

        await store.send(.safari(.gitHub)) {
            $0.url = URL(string: "https://github.com/nnsnodnb/ssl-certificates-check-ios")!
        }
    }

    @MainActor
    func testReset() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(
                version: "v1.0.0-test",
                url: URL(string: "https://github.com/nnsnodnb/ssl-certificates-check-ios")
            )
        ) {
            InfoReducer()
        }

        await store.send(.url(nil)) {
            $0.url = nil
        }
    }

    @MainActor
    func testNoneEffect() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test")
        ) {
            InfoReducer()
        }

        await store.send(.url(nil))
    }
}
