//
//  SearchReducer.swift
//
//
//  Created by Yuya Oka on 2023/10/13.
//

import ComposableArchitecture
import Foundation
import InfoFeature

package struct SearchReducer: Reducer {
    // MARK: - State
    package struct State: Equatable {
        // MARK: - Properties
        var info: InfoReducer.State?
        var searchButtonDisabled = true
        var text: String = ""
        var isLoading = false

        // MARK: - Initialize
        package init(info: InfoReducer.State? = nil) {
            self.info = info
        }
    }

    // MARK: - Action
    package enum Action {
        case textChanged(String)
        case openInfo
        case dismissInfo
        case checkURL
        case search
        case info(InfoReducer.Action)
    }

    // MARK: - Properties
    @Dependency(\.bundle)
    private var bundle

    // MARK: - Body
    package var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .textChanged(text):
                state.text = text
                return .send(.checkURL)
            case .openInfo:
                let version = bundle.shortVersionString()
                state.info = .init(version: "v\(version)")
                return .none
            case .dismissInfo, .info(.dismiss):
                state.info = nil
                return .none
            case .checkURL:
                guard !state.text.isEmpty,
                      let url = URL(string: "https://\(state.text)"),
                      let host = url.host(),
                      !host.isEmpty,
                      host.split(separator: ".").count > 1 else {
                    state.searchButtonDisabled = true
                    return .none
                }
                state.searchButtonDisabled = false
                return .none
            case .search:
                // TODO: Search
                return .none
            case .info:
                return .none
            }
        }
        .ifLet(\.info, action: /Action.info) {
            InfoReducer()
        }
    }
}
