//
//  TestSearchReducerNavigationPathChanged.swift
//  
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
@testable import SearchFeature
import XCTest

@MainActor
final class TestSearchReducerNavigationPathChanged: XCTestCase {
    func testResetDestinations() async throws {
        let x509 = X509.stub
        let store = TestStore(
            initialState: SearchReducer.State(
                searchButtonDisabled: false,
                text: "example.com",
                searchableURL: URL(string: "https://example.com"),
                searchResult: .init(SearchResultReducer.State(x509: x509), id: x509),
                destinations: [.searchResult]
            )
        ) {
            SearchReducer()
        }

        await store.send(.navigationPathChanged([])) {
            $0.destinations = []
            $0.searchResult = nil
        }
    }

    func testRemoveSearchResultDetail() async throws {
        let x509 = X509.stub
        guard let certificate = x509.certificates.first else {
            XCTFail("Certificate is empty")
            return
        }
        let store = TestStore(
            initialState: SearchReducer.State(
                searchButtonDisabled: false,
                text: "example.com",
                searchableURL: URL(string: "https://example.com"),
                searchResult: .init(SearchResultReducer.State(x509: x509), id: x509),
                searchResultDetail: .init(SearchResultDetailReducer.State(certificate: certificate), id: certificate),
                destinations: [.searchResult, .searchResultDetail]
            )
        ) {
            SearchReducer()
        }

        await store.send(.navigationPathChanged([.searchResult])) {
            $0.destinations = [.searchResult]
            $0.searchResultDetail = nil
        }
    }
}
