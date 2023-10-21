//
//  SearchResultReducer.swift
//
//
//  Created by Yuya Oka on 2023/10/21.
//

import ComposableArchitecture
import Foundation

package struct SearchResultReducer: Reducer {
    // MARK: - State
    package struct State: Equatable {
        // MARK: - Properties
        package let certificates: IdentifiedArrayOf<X509.Certificate>

        // MARK: - Initialize
        package init(x509: X509) {
            self.certificates = .init(uniqueElements: x509.certificates)
        }
    }

    // MARK: - Action
    package enum Action: Equatable {
        case selectCertificate(X509.Certificate)
    }

    // MARK: - Body
    package var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .selectCertificate:
                return .none
            }
        }
    }
}
