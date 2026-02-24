//
//  TestLicenseListReducerFetchLicensesResponse.swift
//
//
//  Created by Yuya Oka on 2023/10/15.
//

import ClientDependencies
import ComposableArchitecture
@testable import LicenseFeature
import Testing

@MainActor
struct TestLicenseListReducerFetchLicensesResponse { // swiftlint:disable:this type_name
  @Test
  func testSuccess() async throws {
    let licenses: [License] = [
      .init(id: "dummy", name: "Dummy OSS", licenseText: "Dummy Text")
    ]
    await withDependencies {
      $0.license.fetchLicenses = { licenses }
    } operation: {
      let store = TestStore(
        initialState: LicenseListReducer.State(),
        reducer: {
          LicenseListReducer()
        },
      )

      await store.send(.fetchLicenses)
      await store.receive(\.fetchLicensesResponse.success, licenses, timeout: 0) {
        $0.licenses = .init(uniqueElements: licenses)
      }
    }
  }
}
