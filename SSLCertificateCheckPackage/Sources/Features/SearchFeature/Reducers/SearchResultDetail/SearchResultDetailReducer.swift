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
package struct SearchResultDetailReducer {
  // MARK: - State
  @ObservableState
  package struct State: Equatable {
    // MARK: - Properties
    package let x509: X509
    @Presents package var paywall: PaywallReducer.State?
    @Shared(.inMemory("key_premium_subscription_is_active"))
    package var isPremiumActive = false
  }

  // MARK: - Action
  package enum Action {
    case appear
    case showPaywall
    case paywall(PresentationAction<PaywallReducer.Action>)
  }

  // MARK: - Body
  package var body: some ReducerOf<Self> {
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
