//
//  TestLicenseListReducerFetchLicensesResponse.swift
//
//
//  Created by Yuya Oka on 2023/10/15.
//

import ComposableArchitecture
import DependenciesInterfaces
@testable import SSLCertificateCheckKit
import Testing

@MainActor
struct TestLicenseListReducerFetchLicensesResponse { // swiftlint:disable:this type_name
  @Test
  func testSuccess() async throws {
    let store = TestStore(
      initialState: LicenseListReducer.State(),
      reducer: {
        LicenseListReducer()
      },
    )

    await store.send(.fetchLicenses)
    await store.receive(\.fetchLicensesResponse.success, LicensesPlugin.licenses) {
      $0.licenses = .init(uniqueElements: LicensesPlugin.licenses)
    }
  }
}
