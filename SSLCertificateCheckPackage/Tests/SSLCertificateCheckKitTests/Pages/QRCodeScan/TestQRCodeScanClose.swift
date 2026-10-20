//
//  TestQRCodeScanClose.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/10/20.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import SSLCertificateCheckKit
import Testing

@MainActor
struct TestQRCodeScanClose {
  @Test
  func testIt() async throws {
    let calledDismiss: LockIsolated<Bool> = .init(false)

    await withDependencies {
      $0.dismiss = .init({ calledDismiss.setValue(true) })
    } operation: {
      let store = TestStore(
        initialState: QRCodeScanFeature.State(),
        reducer: {
          QRCodeScanFeature()
        },
      )

      await store.send(.close)
    }

    #expect(calledDismiss.value)
  }
}
