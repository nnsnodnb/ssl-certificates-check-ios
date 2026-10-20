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
    public var recognizedURL: URL?
  }

  // MARK: - Dependency
  @Dependency(\.dismiss)
  private var dismiss

  // MARK: - Action
  public enum Action {
    case close
    case changedRecognizedURL(URL?)
    case selectedHost(String)
    case delegate(Delegate)

    // MARK: - Delegate
    @CasePathable
    public enum Delegate {
      case selectedHost(String)
    }
  }

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .close:
        return .run(
          operation: { _ in
            await dismiss()
          },
        )
      case let .changedRecognizedURL(url):
        state.recognizedURL = url
        return .none
      case let .selectedHost(host):
        return .send(.delegate(.selectedHost(host)))
      case .delegate:
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
    NavigationStack(
      root: {
        scanner
          .toolbar {
            ToolbarItem(placement: .cancellationAction) {
              if #available(iOS 26.0, *) {
                Button(role: .cancel) {
                  store.send(.close)
                }
              } else {
                Button(
                  action: {
                    store.send(.close)
                  },
                  label: {
                    Image(systemSymbol: .xmark)
                  },
                )
              }
            }
          }
          .toolbarBackground(.hidden, for: .navigationBar)
          .overlay(alignment: .bottom) {
            if let url = store.recognizedURL, let host = url.host() {
              Button(
                action: {
                  store.send(.selectedHost(host))
                },
                label: {
                  Label(
                    title: {
                      Text(host)
                        .font(.system(size: 14))
                    },
                    icon: {
                      Image(systemSymbol: .link)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                    },
                  )
                  .foregroundStyle(Color.white)
                  .padding(.vertical, 4)
                  .padding(.horizontal, 8)
                  .background(Color.yellow, in: RoundedRectangle(cornerRadius: 8))
                },
              )
              .frame(alignment: .bottom)
            }
          }
      },
    )
  }

  private var scanner: some View {
    #if targetEnvironment(simulator)
    Text("iOS Simulator is not supported camera feature. Please use phsical device.")
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .ignoresSafeArea(.all)
    #else
    QRCodeScanner(
      recognizedURL: $store.recognizedURL.sending(\.changedRecognizedURL),
      selectedAction: { host in
        store.send(.selectedHost(host))
      }
    )
    .ignoresSafeArea(.all)
    #endif
  }
}

#Preview {
  QRCodeScanPage(
    store: .init(
      initialState: QRCodeScanFeature.State(
        recognizedURL: URL(string: "https://example.com"),
      ),
      reducer: {
        QRCodeScanFeature()
      },
    ),
  )
}
