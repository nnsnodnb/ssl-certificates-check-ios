//
//  TestSearchReducerSearch.swift
//  
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
@testable import SearchFeature
import X509Parser
import XCTest

@MainActor
final class TestSearchReducerSearch: XCTestCase {
    func testEmptyText() async throws {
        let store = TestStore(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
        }

        await store.send(.search)
    }

    func testInvalidText() async throws {
        let store = TestStore(
            initialState: SearchReducer.State(
                searchButtonDisabled: true,
                text: "example.",
                searchableURL: nil
            )
        ) {
            SearchReducer()
        }

        await store.send(.search)
    }

    func testValidTextSuccessResponse() async throws {
        let x509 = X509.stub
        let search = SearchClient(
            fetchCertificates: { _ in [x509] }
        )
        let store = TestStore(
            initialState: SearchReducer.State(
                searchButtonDisabled: false,
                text: "example.com",
                searchableURL: URL(string: "https://example.com")
            )
        ) {
            SearchReducer()
                .dependency(search)
        }

        await store.send(.search) {
            $0.isLoading = true
        }
        await store.receive(\.searchResponse, .success([x509]), timeout: 0) {
            $0.isLoading = false
            $0.destinations = [.searchResult]
            $0.searchResult = .init(SearchResultReducer.State(certificates: .init(uniqueElements: [x509])), id: [x509])
        }
    }

    func testValidTextFailureResponse() async throws {
        enum Error: Swift.Error {
            case testError
        }

        let search = SearchClient(
            fetchCertificates: { _ in throw Error.testError }
        )
        let store = TestStore(
            initialState: SearchReducer.State(
                searchButtonDisabled: false,
                text: "example.com",
                searchableURL: URL(string: "https://example.com")
            )
        ) {
            SearchReducer()
                .dependency(search)
        }

        await store.send(.search) {
            $0.isLoading = true
        }
        await store.receive(\.searchResponse, .failure(.search), timeout: 0) {
            $0.isLoading = false
            $0.alert = AlertState(
                title: {
                    TextState("Failed to obtain certificate")
                },
                actions: {
                    ButtonState(
                        label: {
                            TextState("Close")
                        }
                    )
                },
                message: {
                    TextState("Please check or re-run the URL.")
                }
            )
        }
    }
}
