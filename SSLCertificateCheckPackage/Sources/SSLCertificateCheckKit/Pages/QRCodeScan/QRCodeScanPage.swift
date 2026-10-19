//
//  QRCodeScanPage.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/10/19.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct QRCodeScanFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    public var recognizedPayload = ""
  }

  // MARK: - Action
  public enum Action {
    case changedRecognizedPayload(String)
  }

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .changedRecognizedPayload(recognizedPayload):
        state.recognizedPayload = recognizedPayload
        return .none
      }
    }
  }
}

public struct QRCodeScanPage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<QRCodeScanFeature>

  // MARK: - Body
  public var body: some View {
    QRCodeScanner(recognizedPayload: $store.recognizedPayload.sending(\.changedRecognizedPayload))
  }
}

#Preview {
  QRCodeScanPage(
    store: .init(
      initialState: QRCodeScanFeature.State(),
      reducer: {
        QRCodeScanFeature()
      },
    ),
  )
}
