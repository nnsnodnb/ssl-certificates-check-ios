//
//  TestSearchReducer.swift
//  
//
//  Created by Yuya Oka on 2023/10/15.
//

import ComposableArchitecture
@testable import SearchFeature
import XCTest

@MainActor
final class TestSearchReducer: XCTestCase { // swiftlint:disable:this type_body_length
    func testTextChanged() async throws {
        let store = TestStore(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
        }

        // invalid
        await store.send(.textChanged("example")) {
            $0.text = "example"
            $0.searchButtonDisabled = true
            $0.searchableURL = nil
        }
        await store.send(.textChanged("example.")) {
            $0.text = "example."
            $0.searchButtonDisabled = true
            $0.searchableURL = nil
        }
        // valid
        await store.send(.textChanged("example.c")) {
            $0.text = "example.c"
            $0.searchButtonDisabled = false
            $0.searchableURL = URL(string: "https://example.c")
        }
        await store.send(.textChanged("example.com")) {
            $0.text = "example.com"
            $0.searchButtonDisabled = false
            $0.searchableURL = URL(string: "https://example.com")
        }
    }

    func testPasteURLChangedValidScheme() async throws {
        let store = TestStore(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
        }

        let url = URL(string: "https://example.com")!
        await store.send(.pasteURLChanged(url))
        await store.receive(.textChanged("example.com"), timeout: 0) {
            $0.text = "example.com"
            $0.searchButtonDisabled = false
            $0.searchableURL = URL(string: "https://example.com")!
        }
    }

    func testPasteURLChangedValidSchemeWithPath() async throws {
        let store = TestStore(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
        }

        let url = URL(string: "https://example.com/hoge/foo")!
        await store.send(.pasteURLChanged(url))
        await store.receive(.textChanged("example.com"), timeout: 0) {
            $0.text = "example.com"
            $0.searchButtonDisabled = false
            $0.searchableURL = URL(string: "https://example.com")!
        }
    }

    func testPasteURLChangedValidSchemeWithoutHost() async throws {
        let store = TestStore(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
        }

        let url = URL(string: "https://")!
        await store.send(.pasteURLChanged(url))
    }

    func testPasteURLChangedInvalidScheme() async throws {
        let store = TestStore(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
        }

        let url = URL(string: "http://example.com")!
        await store.send(.pasteURLChanged(url))
    }

    func testUniversalLinksChangedURLValidURL() async throws {
        let store = TestStore(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
        }

        let url = URL(string: "https://nnsnodnb.moe/ssl-certificates-check-ios?encodedURL=aHR0cHM6Ly9leGFtcGxlLmNvbQ==")!
        await store.send(.universalLinksURLChanged(url))
        await store.receive(.textChanged("example.com"), timeout: 0) {
            $0.text = "example.com"
            $0.searchButtonDisabled = false
            $0.searchableURL = URL(string: "https://example.com")
        }
    }

    func testUniversalLinksChangedURLValidURLWhenOpenedInfo() async throws {
        let store = TestStore(
            initialState: SearchReducer.State(info: .init(version: "v1.0.0-test"))
        ) {
            SearchReducer()
        }

        let url = URL(string: "https://nnsnodnb.moe/ssl-certificates-check-ios?encodedURL=aHR0cHM6Ly9leGFtcGxlLmNvbQ==")!
        await store.send(.universalLinksURLChanged(url)) {
            $0.info = nil
        }
        await store.receive(.textChanged("example.com"), timeout: 0) {
            $0.text = "example.com"
            $0.searchButtonDisabled = false
            $0.searchableURL = URL(string: "https://example.com")
        }
    }

    func testUniversalLinksChangedURLValidURLWhenOpenedSearchResult() async throws {
        let store = TestStore(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
        }

        await store.send(.navigationPathChanged([.searchResult])) {
            $0.destinations = [.searchResult]
        }

        let url = URL(string: "https://nnsnodnb.moe/ssl-certificates-check-ios?encodedURL=aHR0cHM6Ly9leGFtcGxlLmNvbQ==")!
        await store.send(.universalLinksURLChanged(url)) {
            $0.destinations = []
        }
        await store.receive(.textChanged("example.com"), timeout: 0) {
            $0.text = "example.com"
            $0.searchButtonDisabled = false
            $0.searchableURL = URL(string: "https://example.com")
        }
    }

    func testUniversalLinksChangedURLNotIncludeEncodedURLQuery() async throws {
        let store = TestStore(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
        }

        let url = URL(string: "https://nnsnodnb.moe/ssl-certificates-check-ios?encoded=aHR0cHM6Ly9leGFtcGxlLmNvbQ==")!
        await store.send(.universalLinksURLChanged(url))
    }

    func testUniversalLinksChangedURLNotBase64Encoded() async throws {
        let store = TestStore(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
        }

        let url = URL(string: "https://nnsnodnb.moe/ssl-certificates-check-ios?encodedURL=aHR0cHM6Ly9leGFtcGxlLmNvbQ")!
        await store.send(.universalLinksURLChanged(url))
    }

    func testUniversalLinksChangedURLInvalidScheme() async throws {
        let store = TestStore(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
        }

        let url = URL(string: "https://nnsnodnb.moe/ssl-certificates-check-ios?encodedURL=aHR0cDovL2V4YW1wbGUuY29t")!
        await store.send(.universalLinksURLChanged(url))
    }

    func testUniversalLinksChangedURLHostIsNone() async throws {
        let store = TestStore(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
        }

        let url = URL(string: "https://nnsnodnb.moe/ssl-certificates-check-ios?encodedURL=aHR0cDovLw==")!
        await store.send(.universalLinksURLChanged(url))
    }

    func testOpenInfo() async throws {
        let store = TestStore(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
        }

        store.dependencies.bundle = .init(
            shortVersionString: { "1.0.0-test" }
        )

        await store.send(.openInfo) {
            $0.info = .init(version: "v1.0.0-test")
        }
    }

    func testDismissInfo() async throws {
        let store = TestStore(
            initialState: SearchReducer.State(info: .init(version: "v1.0.0-test"))
        ) {
            SearchReducer()
        }

        store.dependencies.bundle = .init(
            shortVersionString: { "1.0.0-test" }
        )

        await store.send(.dismissInfo) {
            $0.info = nil
        }
    }

    func testSearchEmptyText() async throws {
        let store = TestStore(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
        }

        await store.send(.search)
    }

    func testSearchInvalidText() async throws {
        let store = TestStore(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
        }

        await store.send(.textChanged("example.")) {
            $0.text = "example."
            $0.searchButtonDisabled = true
            $0.searchableURL = nil
        }
        await store.send(.search)
    }

    func testSearchValidTextSuccessResponse() async throws {
        let store = TestStore(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
        }

        let x509 = X509.stub
        store.dependencies.search = .init(
            fetchCertificates: { _ in x509 }
        )

        await store.send(.textChanged("example.com")) {
            $0.text = "example.com"
            $0.searchButtonDisabled = false
            $0.searchableURL = URL(string: "https://example.com")
        }
        await store.send(.search) {
            $0.isLoading = true
        }
        await store.receive(.searchResponse(.success(x509)), timeout: 0) {
            $0.isLoading = false
            $0.destinations = [.searchResult]
            $0.searchResult = .init(SearchResultReducer.State(x509: x509), id: x509)
        }
    }

    func testSearchValidTextFailureResponse() async throws {
        let store = TestStore(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
        }

        enum Error: Swift.Error {
            case testError
        }

        store.dependencies.search = .init(
            fetchCertificates: { _ in throw Error.testError }
        )

        await store.send(.textChanged("example.com")) {
            $0.text = "example.com"
            $0.searchButtonDisabled = false
            $0.searchableURL = URL(string: "https://example.com")
        }
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

    func testCheckFirstExperienceIsCheckFirstExperienceIsFalse() async throws {
        let store = TestStore(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
        }

        await store.send(.checkFirstExperience)
    }

    func testCheckFirstExperienceIsCheckFirstExperienceIsTrueWasRequestReviewFinishFirstSearchExperienceIsFalse() async throws {
        let store = TestStore(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
        }

        let x509 = X509.stub
        store.dependencies.search = .init(
            fetchCertificates: { _ in x509 }
        )
        store.dependencies.keyValueStore = .init(
            bool: { _ in false },
            setBool: { _, _ in }
        )

        await store.send(.textChanged("example.com")) {
            $0.text = "example.com"
            $0.searchButtonDisabled = false
            $0.searchableURL = URL(string: "https://example.com")
        }
        await store.send(.search) {
            $0.isLoading = true
        }
        await store.receive(.searchResponse(.success(x509)), timeout: 0) {
            $0.isLoading = false
            $0.destinations = [.searchResult]
            $0.searchResult = .init(SearchResultReducer.State(x509: x509), id: x509)
        }
        guard let certificate = x509.certificates.first else {
            XCTFail("Certificate is empty")
            return
        }
        await store.send(.searchResult(.selectCertificate(certificate))) {
            $0.destinations = [.searchResult, .searchResultDetail]
            $0.searchResultDetail = .init(SearchResultDetailReducer.State(certificate: certificate), id: certificate)
        }
        await store.send(.searchResultDetail(.appear)) {
            $0.isCheckFirstExperience = true
        }
        await store.send(.checkFirstExperience) {
            $0.isCheckFirstExperience = false
        }
        await store.receive(.checkFirstExperienceResponse(.success(false)), timeout: 0) {
            $0.isRequestReview = true
        }
    }

    func testCheckFirstExperienceIsCheckFirstExperienceIsTrueWasRequestReviewFinishFirstSearchExperienceIsTrue() async throws {
        let store = TestStore(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
        }

        let x509 = X509.stub
        store.dependencies.search = .init(
            fetchCertificates: { _ in x509 }
        )
        store.dependencies.keyValueStore = .init(
            bool: { _ in true },
            setBool: { _, _ in }
        )

        await store.send(.textChanged("example.com")) {
            $0.text = "example.com"
            $0.searchButtonDisabled = false
            $0.searchableURL = URL(string: "https://example.com")
        }
        await store.send(.search) {
            $0.isLoading = true
        }
        await store.receive(.searchResponse(.success(x509)), timeout: 0) {
            $0.isLoading = false
            $0.destinations = [.searchResult]
            $0.searchResult = .init(SearchResultReducer.State(x509: x509), id: x509)
        }
        guard let certificate = x509.certificates.first else {
            XCTFail("Certificate is empty")
            return
        }
        await store.send(.searchResult(.selectCertificate(certificate))) {
            $0.destinations = [.searchResult, .searchResultDetail]
            $0.searchResultDetail = .init(SearchResultDetailReducer.State(certificate: certificate), id: certificate)
        }
        await store.send(.searchResultDetail(.appear)) {
            $0.isCheckFirstExperience = true
        }
        await store.send(.checkFirstExperience) {
            $0.isCheckFirstExperience = false
        }
        await store.receive(.checkFirstExperienceResponse(.success(true)), timeout: 0)
    }

    func testNavigationPathChanged() async throws {
        let store = TestStore(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
        }

        let x509 = X509.stub
        store.dependencies.search = .init(
            fetchCertificates: { _ in x509 }
        )

        await store.send(.textChanged("example.com")) {
            $0.text = "example.com"
            $0.searchButtonDisabled = false
            $0.searchableURL = URL(string: "https://example.com")
        }
        await store.send(.search) {
            $0.isLoading = true
        }
        await store.receive(.searchResponse(.success(x509)), timeout: 0) {
            $0.isLoading = false
            $0.destinations = [.searchResult]
            $0.searchResult = .init(SearchResultReducer.State(x509: x509), id: x509)
        }
        await store.send(.navigationPathChanged([])) {
            $0.destinations = []
            $0.searchResult = nil
        }
    }

    func testInfoDismiss() async throws {
        let store = TestStore(
            initialState: SearchReducer.State(info: .init(version: "v1.0.0-test"))
        ) {
            SearchReducer()
        }

        await store.send(.info(.dismiss)) {
            $0.info = nil
        }
    }

    func testSearchResultSelectCertificate() async throws {
        let store = TestStore(
            initialState: SearchReducer.State(info: .init(version: "v1.0.0-test"))
        ) {
            SearchReducer()
        }

        let x509 = X509.stub
        store.dependencies.search = .init(
            fetchCertificates: { _ in x509 }
        )

        await store.send(.textChanged("example.com")) {
            $0.text = "example.com"
            $0.searchButtonDisabled = false
            $0.searchableURL = URL(string: "https://example.com")
        }
        await store.send(.search) {
            $0.isLoading = true
        }
        await store.receive(.searchResponse(.success(x509)), timeout: 0) {
            $0.isLoading = false
            $0.destinations = [.searchResult]
            $0.searchResult = .init(SearchResultReducer.State(x509: x509), id: x509)
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

    func testAlertDismiss() async throws {
        let store = TestStore(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
        }

        enum Error: Swift.Error {
            case testError
        }

        store.dependencies.search = .init(
            fetchCertificates: { _ in throw Error.testError }
        )

        await store.send(.textChanged("example.com")) {
            $0.text = "example.com"
            $0.searchButtonDisabled = false
            $0.searchableURL = URL(string: "https://example.com")
        }
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
        await store.send(.alert(.dismiss)) {
            $0.alert = nil
        }
    }
} // swiftlint:disable:this file_length
