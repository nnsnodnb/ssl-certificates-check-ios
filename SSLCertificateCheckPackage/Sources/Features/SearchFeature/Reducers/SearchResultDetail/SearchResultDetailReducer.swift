//
//  SearchResultDetailReducer.swift
//
//
//  Created by Yuya Oka on 2023/10/21.
//

import ComposableArchitecture
import Foundation
import X509Parser

@Reducer
package struct SearchResultDetailReducer {
    // MARK: - State
    package struct State: Equatable {
        // MARK: - Properties
        package let x509: X509
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
