//
//  ConsentReducer.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/18.
//

import ClientDependencies
import ComposableArchitecture
import Dependencies
import Foundation
import MemberwiseInit

@Reducer
@MemberwiseInit(.package)
package struct ConsentReducer: Sendable {
  // MARK: - State
  @ObservableState
  @MemberwiseInit(.package)
  package struct State: Equatable, Sendable {
  }

  // MARK: - Action
  package enum Action: Sendable {
    case showConsent
    case completed
    case delegate(Delegate)

    // MARK: - Delegate
    @CasePathable
    package enum Delegate: Sendable {
      case completedConsent
    }
  }

  // MARK: - Dependency
  @Dependency(\.consentInformation)
  private var consentInformation

  // MARK: - Body
  package var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .showConsent:
        return .run(
          operation: { send in
            guard try await consentInformation.requestConsent() else {
              await send(.completed)
              return
            }
            try await consentInformation.load()
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
