//
//  TestInfoReducerSafari.swift
//
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
import Foundation
@testable import InfoFeature
import XCTest

@MainActor
final class TestInfoReducerSafari: XCTestCase {
    func testGitHubURL() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test")
        ) {
            InfoReducer()
        }

        await store.send(.safari(.gitHub)) {
            $0.url = URL(string: "https://github.com/nnsnodnb/ssl-certificates-check-ios")!
        }
    }

    func testXTwitterURL() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test")
        ) {
            InfoReducer()
        }

        await store.send(.safari(.xTwitter)) {
            $0.url = URL(string: "https://x.com/nnsnodnb")!
        }
    }

    func testResetGitHubURL() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test")
        ) {
            InfoReducer()
        }

        await store.send(.safari(.gitHub)) {
            $0.url = URL(string: "https://github.com/nnsnodnb/ssl-certificates-check-ios")!
        }
        await store.send(.safari(nil)) {
            $0.url = nil
        }
    }

    func testResetXTwitterURL() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test")
        ) {
            InfoReducer()
        }

        await store.send(.safari(.xTwitter)) {
            $0.url = URL(string: "https://x.com/nnsnodnb")!
        }
        await store.send(.safari(nil)) {
            $0.url = nil
        }
    }

    func testNoneEffect() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test")
        ) {
            InfoReducer()
        }

        await store.send(.safari(nil))
    }
}
