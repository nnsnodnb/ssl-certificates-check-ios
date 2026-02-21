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
package struct RootReducer: Sendable {
    // MARK: - State
    package struct State: Equatable, Sendable {
        package let requestStartRewardAdUnitID: String
        package let searchPageBottomBannerAdUnitID: String
        package var checkSubscription: CheckSubscriptionReducer.State?
        package var consent: ConsentReducer.State?
        package var search: SearchReducer.State?
    }

    // MARK: - Action
    package enum Action: Sendable {
        case showCheckSubscription
        case showConsent
        case checkSubscription(CheckSubscriptionReducer.Action)
        case consent(ConsentReducer.Action)
        case search(SearchReducer.Action)
    }

    // MARK: - Body
    package var body: some ReducerOf<Self> {
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
