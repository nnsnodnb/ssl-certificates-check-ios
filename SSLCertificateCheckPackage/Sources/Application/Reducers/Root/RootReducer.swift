//
//  RootReducer.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/18.
//

import ComposableArchitecture
import ConsentFeature
import Foundation
import SearchFeature
import SubscriptionFeature

@Reducer
public struct RootReducer: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    public let requestStartRewardAdUnitID: String
    public let searchPageBottomBannerAdUnitID: String
    public var checkSubscription: CheckSubscriptionReducer.State?
    public var consent: ConsentReducer.State?
    public var search: SearchReducer.State?
  }

  // MARK: - Action
  public enum Action {
    case showCheckSubscription
    case showConsent
    case checkSubscription(CheckSubscriptionReducer.Action)
    case consent(ConsentReducer.Action)
    case search(SearchReducer.Action)
  }

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .showCheckSubscription:
        state.checkSubscription = .init()
        return .none
      case .showConsent:
        state.consent = .init()
        return .none
      case .checkSubscription(.delegate(.completed)):
        return .send(.showConsent)
      case .checkSubscription:
        return .none
      case .consent(.delegate(.completedConsent)):
        state.consent = nil
        state.search = .init()
        return .none
      case .consent:
        return .none
      case .search:
        return .none
      }
    }
    .ifLet(\.checkSubscription, action: \.checkSubscription) {
      CheckSubscriptionReducer()
    }
    .ifLet(\.consent, action: \.consent) {
      ConsentReducer()
    }
    .ifLet(\.search, action: \.search) {
      SearchReducer()
    }
  }
}
