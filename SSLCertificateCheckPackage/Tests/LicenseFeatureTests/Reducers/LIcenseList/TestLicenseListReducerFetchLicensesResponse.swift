//
//  TestLicenseListReducerFetchLicensesResponse.swift
//
//
//  Created by Yuya Oka on 2023/10/15.
//

import ComposableArchitecture
@testable import LicenseFeature
import XCTest

@MainActor
final class TestLicenseListReducerFetchLicensesResponse: XCTestCase { // swiftlint:disable:this type_name
    func testSuccess() async throws {
        let store = TestStore(
            initialState: LicenseListReducer.State()
        ) {
            LicenseListReducer()
        }

        let licenses: [License] = [
            .init(id: "dummy", name: "Dummy OSS", licenseText: "Dummy Text")
        ]
        store.dependencies.license = .init(
            fetchLicenses: { licenses }
        )

        await store.send(.fetchLicenses)
        await store.receive(\.fetchLicensesResponse.success, licenses, timeout: 0) {
            $0.licenses = .init(uniqueElements: licenses)
        }
    }
}
