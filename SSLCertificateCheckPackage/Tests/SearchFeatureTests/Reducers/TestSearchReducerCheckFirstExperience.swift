//
//  TestSearchReducerCheckFirstExperience.swift
//  
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
@testable import SearchFeature
import XCTest

@MainActor
final class TestSearchReducerCheckFirstExperience: XCTestCase {
    func testIsCheckFirstExperienceIsFalse() async throws {
        let store = TestStore(
            initialState: SearchReducer.State(isCheckFirstExperience: false)
        ) {
            SearchReducer()
        }

        await store.send(.checkFirstExperience)
    }

    func testIsCheckFirstExperienceIsTrueWasRequestReviewFinishFirstSearchExperienceIsFalse() async throws {
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
                isCheckFirstExperience: true,
                destinations: [.searchResult, .searchResultDetail]
            )
        ) {
            SearchReducer()
        }

        store.dependencies.keyValueStore = .init(
            bool: { _ in false },
            setBool: { _, _ in }
        )

        await store.send(.checkFirstExperience) {
            $0.isCheckFirstExperience = false
        }
        await store.receive(.checkFirstExperienceResponse(.success(false)), timeout: 0) {
            $0.isRequestReview = true
        }
    }

    func testIsCheckFirstExperienceIsTrueWasRequestReviewFinishFirstSearchExperienceIsTrue() async throws {
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
                isCheckFirstExperience: true,
                destinations: [.searchResult, .searchResultDetail]
            )
        ) {
            SearchReducer()
        }

        store.dependencies.keyValueStore = .init(
            bool: { _ in true },
            setBool: { _, _ in }
        )

        await store.send(.checkFirstExperience) {
            $0.isCheckFirstExperience = false
        }
        await store.receive(.checkFirstExperienceResponse(.success(true)), timeout: 0)
    }
}
