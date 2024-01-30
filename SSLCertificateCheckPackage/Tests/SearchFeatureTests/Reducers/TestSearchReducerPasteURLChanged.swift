//
//  TestSearchReducerPasteURLChanged.swift
//
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
@testable import SearchFeature
import XCTest

@MainActor
final class TestSearchReducerPasteURLChanged: XCTestCase {
    func testValidScheme() async throws {
        let store = TestStore(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
        }

        let url = URL(string: "https://example.com")!
        await store.send(.pasteURLChanged(url))
        await store.receive(\.textChanged, "example.com", timeout: 0) {
            $0.text = "example.com"
            $0.searchButtonDisabled = false
            $0.searchableURL = URL(string: "https://example.com")!
        }
    }

    func testValidSchemeWithPath() async throws {
        let store = TestStore(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
        }

        let url = URL(string: "https://example.com/hoge/foo")!
        await store.send(.pasteURLChanged(url))
        await store.receive(\.textChanged, "example.com", timeout: 0) {
            $0.text = "example.com"
            $0.searchButtonDisabled = false
            $0.searchableURL = URL(string: "https://example.com")!
        }
    }

    func testValidSchemeWithoutHost() async throws {
        let store = TestStore(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
        }

        let url = URL(string: "https://")!
        await store.send(.pasteURLChanged(url))
    }

    func testInvalidScheme() async throws {
        let store = TestStore(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
        }

        let url = URL(string: "http://example.com")!
        await store.send(.pasteURLChanged(url))
    }
}
