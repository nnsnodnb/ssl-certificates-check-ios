//
//  TestLicenseListReducerFetchLicensesResponse.swift
//
//
//  Created by Yuya Oka on 2023/10/15.
//

import ComposableArchitecture
@testable import LicenseFeature
import XCTest

final class TestLicenseListReducerFetchLicensesResponse: XCTestCase { // swiftlint:disable:this type_name
    @MainActor
    func testSuccess() async throws {
        let licenses: [License] = [
            .init(id: "dummy", name: "Dummy OSS", licenseText: "Dummy Text")
        ]
        let licence = LicenseClient(
            fetchLicenses: { licenses }
        )
        let store = TestStore(
            initialState: LicenseListReducer.State()
        ) {
            LicenseListReducer()
                .dependency(licence)
        }

        await store.send(.fetchLicenses)
        await store.receive(\.fetchLicensesResponse.success, licenses, timeout: 0) {
            $0.licenses = .init(uniqueElements: licenses)
        }
    }
}
