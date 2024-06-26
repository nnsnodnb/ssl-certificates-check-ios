//
//  TestSearchReducerCheckFirstExperience.swift
//  
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
@testable import SearchFeature
import X509Parser
import XCTest

final class TestSearchReducerCheckFirstExperience: XCTestCase {
    @MainActor
    func testIsCheckFirstExperienceIsFalse() async throws {
        let store = TestStore(
            initialState: SearchReducer.State(isCheckFirstExperience: false)
        ) {
            SearchReducer()
        }

        await store.send(.checkFirstExperience)
    }

    @MainActor
    func testIsCheckFirstExperienceIsTrueWasRequestReviewFinishFirstSearchExperienceIsFalse() async throws {
        let x509 = X509.stub
        let keyValueStore = KeyValueStoreClient(
            getWasRequestReviewFinishFirstSearchExperience: { false },
            setWasRequestReviewFinishFirstSearchExperience: { _ in }
        )
        let store = TestStore(
            initialState: SearchReducer.State(
                searchButtonDisabled: false,
                text: "example.com",
                searchableURL: URL(string: "https://example.com"),
                searchResult: .init(SearchResultReducer.State(certificates: .init(uniqueElements: [x509])), id: [x509]),
                searchResultDetail: .init(SearchResultDetailReducer.State(x509: x509), id: x509),
                isCheckFirstExperience: true,
                destinations: [.searchResult, .searchResultDetail]
            )
        ) {
            SearchReducer()
                .dependency(keyValueStore)
        }

        await store.send(.checkFirstExperience) {
            $0.isCheckFirstExperience = false
        }
        await store.receive(\.checkFirstExperienceResponse, .success(false), timeout: 0) {
            $0.isRequestReview = true
        }
    }

    @MainActor
    func testIsCheckFirstExperienceIsTrueWasRequestReviewFinishFirstSearchExperienceIsTrue() async throws {
        let x509 = X509.stub
        let keyValueStore = KeyValueStoreClient(
            getWasRequestReviewFinishFirstSearchExperience: { true },
            setWasRequestReviewFinishFirstSearchExperience: { _ in }
        )
        let store = TestStore(
            initialState: SearchReducer.State(
                searchButtonDisabled: false,
                text: "example.com",
                searchableURL: URL(string: "https://example.com"),
                searchResult: .init(SearchResultReducer.State(certificates: .init(uniqueElements: [x509])), id: [x509]),
                searchResultDetail: .init(SearchResultDetailReducer.State(x509: x509), id: x509),
                isCheckFirstExperience: true,
                destinations: [.searchResult, .searchResultDetail]
            )
        ) {
            SearchReducer()
                .dependency(keyValueStore)
        }

        await store.send(.checkFirstExperience) {
            $0.isCheckFirstExperience = false
        }
        await store.receive(\.checkFirstExperienceResponse, .success(true), timeout: 0)
    }
}
