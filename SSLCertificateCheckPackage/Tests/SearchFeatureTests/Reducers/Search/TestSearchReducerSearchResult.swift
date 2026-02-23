//
//  TestSearchReducerSearchResult.swift
//  
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
@testable import SearchFeature
import X509Parser
import XCTest

final class TestSearchReducerSearchResult: XCTestCase {
    @MainActor
    func testPreapreSearchResultDetail() async throws {
        let x509 = X509.stub
        let store = TestStore(
            initialState: SearchReducer.State(
                info: .init(version: "v1.0.0-test"),
                searchButtonDisabled: false,
                text: "example.com",
                searchableURL: URL(string: "https://example.com"),
                searchResult: .init(SearchResultReducer.State(certificates: .init(uniqueElements: [x509])), id: [x509]),
                destinations: [.searchResult]
            )
        ) {
            SearchReducer()
        }

        await store.send(.searchResult(.selectCertificate(x509))) {
            $0.destinations = [.searchResult, .searchResultDetail]
            $0.searchResultDetail = .init(SearchResultDetailReducer.State(x509: x509), id: x509)
        }
    }
}
