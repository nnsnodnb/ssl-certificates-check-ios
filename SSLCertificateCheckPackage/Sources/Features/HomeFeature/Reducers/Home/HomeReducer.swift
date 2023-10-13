//
//  HomeReducer.swift
//
//
//  Created by Yuya Oka on 2023/10/13.
//

import ComposableArchitecture
import Foundation

package struct HomeReducer: Reducer {
    // MARK: - State
    package struct State: Equatable {
        package init() {}
    }

    // MARK: - Action
    package enum Action {
    }

    package var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}
