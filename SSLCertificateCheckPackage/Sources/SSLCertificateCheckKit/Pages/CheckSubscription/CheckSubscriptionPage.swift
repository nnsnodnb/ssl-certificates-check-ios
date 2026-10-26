//
//  CheckSubscriptionPage.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/21.
//

import ComposableArchitecture
import Dependencies
import DependenciesInterfaces
import SwiftUI

@Reducer
public struct CheckSubscriptionReducer: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable, Sendable {
    @Shared(.inMemory(.isPremiumSubscriptionIsActive))
    public var isPremiumActive = false
  }

  // MARK: - Action
  public enum Action {
    case onAppear
    case internalAction(InternalAction)
    case delegate(Delegate)

    // MARK: - InternalAction
    @CasePathable
    public enum InternalAction {
      case setIsPremiumActive(Bool)
    }

    // MARK: - Delegate
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
            let isActive = try await revenueCat.isPremiumActive()
            await send(.internalAction(.setIsPremiumActive(isActive)))
          },
          catch: { _, send in
            await send(.internalAction(.setIsPremiumActive(false)))
          }
        )
      case let .internalAction(.setIsPremiumActive(isActive)):
        state.$isPremiumActive.withLock { $0 = isActive }
        return .send(.delegate(.completed))
      case .internalAction:
        return .none
      case .delegate:
        return .none
      }
    }
  }
}

public struct CheckSubscriptionPage: View {
  // MARK: - Properties
  let store: StoreOf<CheckSubscriptionReducer>

  public var body: some View {
    ProgressView()
      .progressViewStyle(.circular)
      .scaleEffect(2)
      .task {
        store.send(.onAppear)
      }
  }
}

#Preview {
  CheckSubscriptionPage(
    store: .init(
      initialState: CheckSubscriptionReducer.State(),
      reducer: {
        CheckSubscriptionReducer()
      },
    )
  )
}
