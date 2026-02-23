//
//  TestSearchReducerSearch.swift
//  
//
//  Created by Yuya Oka on 2023/10/22.
//

import ClientDependencies
import ComposableArchitecture
import Foundation
@testable import SearchFeature
import Testing
import X509Parser

@MainActor
struct TestSearchReducerSearch {
    @Test
    func testEmptyText() async throws {
        let store = TestStore(
            initialState: SearchReducer.State(),
            reducer: {
                SearchReducer()
            },
        )

        await store.send(.search(URL(string: "https://example.com")!))
    }

    @Test
    func testInvalidText() async throws {
        let store = TestStore(
            initialState: SearchReducer.State(
                searchButtonDisabled: true,
                text: "example.",
                searchableURL: nil
            ),
            reducer: {
                SearchReducer()
            },
        )

        await store.send(.search(URL(string: "https://example.com")!))
    }

    @Test
    func testValidTextSuccessResponse() async throws {
        let x509 = X509.stub
        await withDependencies {
            $0.search.fetchCertificates = { _ in [x509] }
        } operation: {
            let store = TestStore(
                initialState: SearchReducer.State(
                    searchButtonDisabled: false,
                    text: "example.com",
                    searchableURL: URL(string: "https://example.com"),
                    isLoading: true,
                ),
                reducer: {
                    SearchReducer()
                },
            )

            await store.send(.search(URL(string: "https://example.com")!))
            await store.receive(\.searchResponse, .success([x509]), timeout: 0) {
                $0.isLoading = false
                $0.destinations = [.searchResult]
                $0.searchResult = .init(SearchResultReducer.State(certificates: .init(uniqueElements: [x509])), id: [x509])
            }
        }
    }

    @Test
    func testValidTextFailureResponse() async throws {
        enum Error: Swift.Error {
            case testError
        }

        await withDependencies {
            $0.search.fetchCertificates = { _ in throw Error.testError }
        } operation: {
            let store = TestStore(
                initialState: SearchReducer.State(
                    searchButtonDisabled: false,
                    text: "example.com",
                    searchableURL: URL(string: "https://example.com"),
                    isLoading: true,
                ),
                reducer: {
                    SearchReducer()
                },
            )

            await store.send(.search(URL(string: "https://example.com")!))
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
}
