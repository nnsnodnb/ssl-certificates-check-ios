//
//  ConsentPage.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/17.
//

import ComposableArchitecture
import DependenciesInterfaces
import SwiftUI

@Reducer
public struct ConsentReducer: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable, Sendable {
  }

  // MARK: - Action
  public enum Action: Sendable {
    case showConsent
    case completed
    case delegate(Delegate)

    // MARK: - Delegate
    @CasePathable
    public enum Delegate: Sendable {
      case completedConsent
    }
  }

  // MARK: - Dependency
  @Dependency(\.consentInformation)
  private var consentInformation

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .showConsent:
        return .run(
          operation: { send in
            guard try await consentInformation.requestConsent() else {
              await send(.completed)
              return
            }
            try await consentInformation.loadAndPresentIfRequired()
            await send(.completed)
          },
        )
      case .completed:
        return .send(.delegate(.completedConsent))
      case .delegate:
        return .none
      }
    }
  }
}

public struct ConsentPage: View {
  // MARK: - Properties
  public let store: StoreOf<ConsentReducer>

  // MARK: - Body
  public var body: some View {
    Color(UIColor.systemBackground.withAlphaComponent(0.000001))
      .ignoresSafeArea(.all)
      .onAppear {
        store.send(.showConsent)
      }
  }
}

#Preview {
  ConsentPage(
    store: .init(
      initialState: .init(),
      reducer: {
        ConsentReducer()
      },
    )
  )
}
