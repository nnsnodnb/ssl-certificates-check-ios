//
//  TestSearchReducerShowQRCodeScan.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/10/20.
//

import ComposableArchitecture
@testable import SSLCertificateCheckKit
import Testing

@MainActor
struct TestSearchReducerShowQRCodeScan {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: SearchReducer.State(),
      reducer: {
        SearchReducer()
      },
    )

    await store.send(.showQRCodeScan) {
      $0.destination = .qrCodeScan(.init())
    }
  }
}
