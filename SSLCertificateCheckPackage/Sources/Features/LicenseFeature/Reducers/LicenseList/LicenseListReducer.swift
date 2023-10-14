//
//  LicenseListReducer.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import ComposableArchitecture
import Foundation

package struct LicenseListReducer: Reducer {
    // MARK: - State
    package struct State: Equatable {
        // MARK: - Initialize
        package init() {
        }
    }

    // MARK: - Action
    package enum Action {
    }

    // MARK: - Initialize
    package init() {
    }

    // MARK: - Body
    package var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}
