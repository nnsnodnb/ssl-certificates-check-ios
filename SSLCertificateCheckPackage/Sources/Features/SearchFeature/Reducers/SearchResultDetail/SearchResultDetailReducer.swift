//
//  SearchResultDetailReducer.swift
//
//
//  Created by Yuya Oka on 2023/10/21.
//

import ComposableArchitecture
import Foundation
import SubscriptionFeature
import X509Parser

@Reducer
public struct SearchResultDetailReducer {
  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    // MARK: - Properties
    public let x509: X509
    @Presents public var paywall: PaywallReducer.State?
    @Shared(.inMemory("key_premium_subscription_is_active"))
    public var isPremiumActive = false
  }

  // MARK: - Action
  public enum Action {
    case appear
    case showPaywall
    case paywall(PresentationAction<PaywallReducer.Action>)
  }

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .appear:
        return .none
      case .showPaywall:
        state.paywall = .init()
        return .none
      case .paywall(.dismiss):
        state.paywall = nil
        return .none
      case .paywall:
        return .none
      }
    }
    .ifLet(\.$paywall, action: \.paywall) {
      PaywallReducer()
    }
  }
}
