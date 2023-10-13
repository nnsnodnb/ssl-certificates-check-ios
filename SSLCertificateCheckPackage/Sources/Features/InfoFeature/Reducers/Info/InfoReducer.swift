//
//  InfoReducer.swift
//
//
//  Created by Yuya Oka on 2023/10/13.
//

import ComposableArchitecture
import Foundation

package struct InfoReducer: Reducer {
    // MARK: - State
    package struct State: Equatable {
        // MARK: - Initialize
        package init() {
        }
    }

    // MARK: - Action
    package enum Action {
        case dismiss
    }

    // MARK: - Initialize
    package init() {
    }

    // MARK: - Body
    package var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .dismiss:
                return .none
            }
        }
    }
}
