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
        let store = TestStore(
            initialState: SearchReducer.State(
                searchButtonDisabled: false,
                text: "example.com",
                searchableURL: URL(string: "https://example.com")
            )
        ) {
            SearchReducer()
        }

        let x509 = X509.stub
        store.dependencies.search = .init(
            fetchCertificates: { _ in [x509] }
        )

        await store.send(.search) {
            $0.isLoading = true
        }
        await store.receive(.searchResponse(.success([x509])), timeout: 0) {
            $0.isLoading = false
            $0.destinations = [.searchResult]
            $0.searchResult = .init(SearchResultReducer.State(certificates: .init(uniqueElements: [x509])), id: [x509])
        }
    }

    func testValidTextFailureResponse() async throws {
        let store = TestStore(
            initialState: SearchReducer.State(
                searchButtonDisabled: false,
                text: "example.com",
                searchableURL: URL(string: "https://example.com")
            )
        ) {
            SearchReducer()
        }

        enum Error: Swift.Error {
            case testError
        }

        store.dependencies.search = .init(
            fetchCertificates: { _ in throw Error.testError }
        )

        await store.send(.search) {
            $0.isLoading = true
        }
        await store.receive(.searchResponse(.failure(Error.testError)), timeout: 0) {
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
