//
//  TestInfoReducerSafari.swift
//
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
import Foundation
@testable import InfoFeature
import Testing

@MainActor
struct TestInfoReducerSafari {
    @Test
    func testGitHubURL() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test"),
            reducer: {
                InfoReducer()
            },
        )

        await store.send(.safari(.gitHub)) {
            $0.url = URL(string: "https://github.com/nnsnodnb/ssl-certificates-check-ios")!
        }
    }

    @Test
    func testXTwitterURL() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test"),
            reducer: {
                InfoReducer()
            },
        )

        await store.send(.safari(.xTwitter)) {
            $0.url = URL(string: "https://x.com/nnsnodnb")!
        }
    }

    @Test
    func testTerms() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test"),
            reducer: {
                InfoReducer()
            },
        )

        await store.send(.safari(.terms)) {
            $0.url = URL(string: "https://github.com/nnsnodnb/ssl-certificates-check-ios/wiki/Terms")!
        }
    }

    @Test
    func testPrivacyPolicy() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test"),
            reducer: {
                InfoReducer()
            },
        )

        await store.send(.safari(.privacyPolicy)) {
            $0.url = URL(string: "https://github.com/nnsnodnb/ssl-certificates-check-ios/wiki/Privacy-Policy")!
        }
    }

    @Test
    func testResetGitHubURL() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test"),
            reducer: {
                InfoReducer()
            },
        )

        await store.send(.safari(.gitHub)) {
            $0.url = URL(string: "https://github.com/nnsnodnb/ssl-certificates-check-ios")!
        }
        await store.send(.safari(nil)) {
            $0.url = nil
        }
    }

    @Test
    func testResetXTwitterURL() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test"),
            reducer: {
                InfoReducer()
            },
        )

        await store.send(.safari(.xTwitter)) {
            $0.url = URL(string: "https://x.com/nnsnodnb")!
        }
        await store.send(.safari(nil)) {
            $0.url = nil
        }
    }

    @Test
    func testResetTerms() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test"),
            reducer: {
                InfoReducer()
            },
        )

        await store.send(.safari(.terms)) {
            $0.url = URL(string: "https://github.com/nnsnodnb/ssl-certificates-check-ios/wiki/Terms")!
        }
        await store.send(.safari(nil)) {
            $0.url = nil
        }
    }

    @Test
    func testResetPrivacyPolicy() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test"),
            reducer: {
                InfoReducer()
            },
        )

        await store.send(.safari(.privacyPolicy)) {
            $0.url = URL(string: "https://github.com/nnsnodnb/ssl-certificates-check-ios/wiki/Privacy-Policy")!
        }
        await store.send(.safari(nil)) {
            $0.url = nil
        }
    }

    @Test
    func testNoneEffect() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test"),
            reducer: {
                InfoReducer()
            },
        )

        await store.send(.safari(nil))
    }
}
