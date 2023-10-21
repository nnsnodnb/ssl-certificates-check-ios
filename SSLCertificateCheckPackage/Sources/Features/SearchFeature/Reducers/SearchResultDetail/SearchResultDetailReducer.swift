//
//  SearchResultDetailReducer.swift
//
//
//  Created by Yuya Oka on 2023/10/21.
//

import ComposableArchitecture
import Foundation

package struct SearchResultDetailReducer: Reducer {
    // MARK: - State
    package struct State: Equatable {
        // MARK: - Properties
        package let certificate: X509.Certificate
    }

    // MARK: - Action
    package enum Action: Equatable {
        case appear
    }

    // MARK: - Body
    package var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .appear:
                return .none
            }
        }
    }
}
