//
//  PaywallReducer.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/23.
//

import ComposableArchitecture
import Dependencies
import Foundation
import MemberwiseInit
import RevenueCat

@Reducer
@MemberwiseInit(.package)
public struct PaywallReducer: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    @Presents public var alert: AlertState<Action.Alert>?
    @Shared(.inMemory("key_premium_subscription_is_active"))
    public var isPremiumActive = false

    // MARK: - Initialize
    public init(alert: AlertState<Action.Alert>? = nil, isPremiumActive: Bool = false) {
      self.alert = alert
      self.$isPremiumActive.withLock { $0 = isPremiumActive }
    }
  }

  // MARK: - Action
  public enum Action {
    case restoreCompleted(any CustomerInfoProtocol)
    case restoreFailure
    case alert(PresentationAction<Alert>)

    // MARK: - Alert
    @CasePathable
    public enum Alert: Equatable {
      case okay
      case close
    }
  }

  // MARK: - Dependency
  @Dependency(\.dismiss)
  private var dismiss

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .restoreCompleted(customerInfo):
        if customerInfo.isPremiumActive {
          state.$isPremiumActive.withLock { $0 = true }
          state.alert = .init(
            title: {
              TextState("Your purchase has been restored.")
            },
            actions: {
              ButtonState(
                action: .okay,
                label: {
                  TextState("OK")
                },
              )
            },
          )
        } else {
          state.$isPremiumActive.withLock { $0 = false }
          state.alert = .init(
            title: {
              TextState("No valid purchases were found.")
            },
          )
        }
        return .none
      case .restoreFailure:
        state.alert = .init(
          title: {
            TextState("Failed to restore purchases.")
          },
          actions: {
            ButtonState(
              action: .close,
              label: {
                TextState("Close")
              },
            )
          },
        )
        return .none
      case .alert(.presented(.okay)):
        state.alert = nil
        return .run(
          operation: { _ in
            await dismiss()
          },
        )
      case .alert:
        state.alert = nil
        return .none
      }
    }
  }
}
