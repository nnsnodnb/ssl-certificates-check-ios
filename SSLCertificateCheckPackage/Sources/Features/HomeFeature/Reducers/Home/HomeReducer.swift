//
//  HomeReducer.swift
//
//
//  Created by Yuya Oka on 2023/10/13.
//

import ComposableArchitecture
import Foundation
import InfoFeature

package struct HomeReducer: Reducer {
    // MARK: - State
    package struct State: Equatable {
        // MARK: - Properties
        package var info: InfoReducer.State?

        // MARK: - Initialize
        package init() {
        }
    }

    // MARK: - Action
    package enum Action {
        case openInfo
        case dismissInfo
        case info(InfoReducer.Action)
    }

    // MARK: - Body
    package var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .openInfo:
                state.info = .init()
                return .none
            case .dismissInfo, .info(.dismiss):
                state.info = nil
                return .none
            }
        }
        .ifLet(\.info, action: /Action.info) {
            InfoReducer()
        }
    }
}
