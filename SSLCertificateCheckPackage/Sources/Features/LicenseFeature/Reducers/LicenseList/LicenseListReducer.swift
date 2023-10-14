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
        // MARK: - Properties
        var licenses: IdentifiedArrayOf<License> = []

        // MARK: - Initialize
        package init() {
        }
    }

    // MARK: - Action
    package enum Action {
        case fetchLicenses
    }

    // MARK: - Properties
    @Dependency(\.license)
    private var license

    // MARK: - Initialize
    package init() {
    }

    // MARK: - Body
    package var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchLicenses:
                let licenses = license.fetchLicenses()
                state.licenses = .init(uniqueElements: licenses)
                return .none
            }
        }
    }
}
