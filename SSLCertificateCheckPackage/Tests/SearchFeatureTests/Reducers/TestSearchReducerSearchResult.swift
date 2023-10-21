//
//  TestSearchReducerSearchResult.swift
//  
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
@testable import SearchFeature
import XCTest

@MainActor
final class TestSearchReducerSearchResult: XCTestCase {
    func testPreapreSearchResultDetail() async throws {
        let x509 = X509.stub
        let store = TestStore(
            initialState: SearchReducer.State(
                info: .init(version: "v1.0.0-test"),
                searchButtonDisabled: false,
                text: "example.com",
                searchableURL: URL(string: "https://example.com"),
                searchResult: .init(SearchResultReducer.State(x509: x509), id: x509),
                destinations: [.searchResult]
            )
        ) {
            SearchReducer()
        }

        guard let certificate = x509.certificates.first else {
            XCTFail("Certificate is empty")
            return
        }
        await store.send(.searchResult(.selectCertificate(certificate))) {
            $0.destinations = [.searchResult, .searchResultDetail]
            $0.searchResultDetail = .init(SearchResultDetailReducer.State(certificate: certificate), id: certificate)
        }
    }
}
