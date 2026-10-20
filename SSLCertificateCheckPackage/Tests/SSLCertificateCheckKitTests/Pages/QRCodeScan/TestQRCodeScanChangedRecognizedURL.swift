//
//  TestQRCodeScanChangedRecognizedURL.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/10/20.
//

import ComposableArchitecture
import Foundation
@testable import SSLCertificateCheckKit
import Testing

@MainActor
struct TestQRCodeScanChangedRecognizedURL {
  @Test
  func testToIsNotNil() async throws {
    let store = TestStore(
      initialState: QRCodeScanFeature.State(),
      reducer: {
        QRCodeScanFeature()
      },
    )

    await store.send(.changedRecognizedURL(URL(string: "https://example.com")!)) {
      $0.recognizedURL = URL(string: "https://example.com")!
    }
  }

  @Test
  func testToNil() async throws {
    let store = TestStore(
      initialState: QRCodeScanFeature.State(
        recognizedURL: URL(string: "https://example.com")!,
      ),
      reducer: {
        QRCodeScanFeature()
      },
    )

    await store.send(.changedRecognizedURL(nil)) {
      $0.recognizedURL = nil
    }
  }
}
