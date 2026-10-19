//
//  QRCodeScanner.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/10/19.
//

import SwiftUI
import VisionKit

public struct QRCodeScanner: UIViewControllerRepresentable {
  // MARK: - Properties
  @Binding public var recognizedPayload: String

  public func makeUIViewController(context: Context) -> DataScannerViewController {
    let viewController = DataScannerViewController(
      recognizedDataTypes: [.barcode(symbologies: [.qr])],
      isHighlightingEnabled: true,
    )
    viewController.delegate = context.coordinator
    try? viewController.startScanning()
    return viewController
  }

  public func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
  }

  public func makeCoordinator() -> Coordinator {
    .init(parent: self)
  }
}

// MARK: - Coordinator
public extension QRCodeScanner {
  final class Coordinator: NSObject, DataScannerViewControllerDelegate {
    // MARK: - Properties
    private let parent: QRCodeScanner

    // MARK: - Initialize
    init(parent: QRCodeScanner) {
      self.parent = parent
    }

    // MARK: - DataScannerViewControllerDelegate
    public func dataScanner(
      _ dataScanner: DataScannerViewController,
      didAdd addedItems: [RecognizedItem],
      allItems: [RecognizedItem],
    ) {
      guard case let .barcode(barcode) = addedItems.first,
            let payloadStringValue = barcode.payloadStringValue else { return }
      parent.recognizedPayload = payloadStringValue
    }

    public func dataScanner(
      _ dataScanner: DataScannerViewController,
      didRemove removedItems: [RecognizedItem],
      allItems: [RecognizedItem],
    ) {
      parent.recognizedPayload = ""
    }

    public func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
      guard case let .barcode(barcode) = item,
            let payloadStringValue = barcode.payloadStringValue,
            let url = URL(string: payloadStringValue) else { return }
      print(url.absoluteString)
    }
  }
}

#Preview {
  @Previewable @State var payload = ""

  QRCodeScanner(recognizedPayload: $payload)
}
