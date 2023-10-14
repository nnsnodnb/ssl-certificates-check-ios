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
final class TestSearchReducer: XCTestCase {
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
            $0.destinations = [.searchResult(x509)]
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
            $0.destinations = [.searchResult(x509)]
        }
        await store.send(.navigationPathChanged([])) {
            $0.destinations = []
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
}
