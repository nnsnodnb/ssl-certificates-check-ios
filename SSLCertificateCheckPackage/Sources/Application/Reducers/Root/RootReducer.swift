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

@Reducer
package struct RootReducer: Sendable {
    // MARK: - State
    package struct State: Equatable, Sendable {
        package let requestStartRewardAdUnitID: String
        package var consent: ConsentReducer.State?
        package var search: SearchReducer.State?
    }

    // MARK: - Action
    package enum Action: Sendable {
        case showConsent
        case consent(ConsentReducer.Action)
        case search(SearchReducer.Action)
    }

    // MARK: - Body
    package var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .showConsent:
                state.consent = .init()
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
        .ifLet(\.consent, action: \.consent) {
            ConsentReducer()
        }
        .ifLet(\.search, action: \.search) {
            SearchReducer()
        }
    }
}
