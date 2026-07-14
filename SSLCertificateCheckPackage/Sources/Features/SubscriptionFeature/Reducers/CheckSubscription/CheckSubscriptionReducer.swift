//
//  CheckSubscriptionReducer.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/21.
//

import ClientDependencies
import ComposableArchitecture
import Dependencies
import Foundation
import MemberwiseInit

@Reducer
@MemberwiseInit(.public)
public struct CheckSubscriptionReducer: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable, Sendable {
    @Shared(.inMemory("key_premium_subscription_is_active"))
    public var isPremiumActive = false
    public var wasSendCompleted = false

    // MARK: - Initialize
    public init(
      isPremiumActive: Bool = false,
      wasSendCompleted: Bool = false,
    ) {
      self.$isPremiumActive.withLock { $0 = isPremiumActive }
      self.wasSendCompleted = wasSendCompleted
    }
  }

  // MARK: - Action
  public enum Action {
    case onAppear
    case gotIsPremiumActive(Bool)
    case delegate(Delegate)

    @CasePathable
    public enum Delegate {
      case completed
    }
  }

  // MARK: - Dependency
  @Dependency(\.revenueCat)
  private var revenueCat

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .run(
          operation: { send in
            for await isActive in try await revenueCat.isPremiumActiveStream() {
              await send(.gotIsPremiumActive(isActive))
            }
          },
          catch: { _, send in
            await send(.gotIsPremiumActive(false))
          }
        )
      case let .gotIsPremiumActive(isActive):
        state.$isPremiumActive.withLock { $0 = isActive }
        if state.wasSendCompleted { return .none }
        state.wasSendCompleted = true
        return .send(.delegate(.completed))
      case .delegate:
        return .none
      }
    }
  }
}
