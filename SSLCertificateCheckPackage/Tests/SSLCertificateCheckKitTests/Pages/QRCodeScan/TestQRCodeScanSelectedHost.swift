//
//  TestQRCodeScanSelectedHost.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/10/20.
//

import ComposableArchitecture
import Foundation
@testable import SSLCertificateCheckKit
import Testing

@MainActor
struct TestQRCodeScanSelectedHost {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: QRCodeScanFeature.State(
        recognizedURL: URL(string: "https://example.com")!,
      ),
      reducer: {
        QRCodeScanFeature()
      },
    )

    await store.send(.selectedHost("example.com"))
    await store.receive(\.delegate.selectedHost, "example.com")
  }
}
