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

    // MARK: - Initialize
    package init() {
    }

    // MARK: - Body
    package var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchLicenses:
                // TODO: Fetch licenses from DI client
                let licenses = LicensesPlugin.licenses.map { License(id: $0.id, name: $0.name, licenseText: $0.licenseText) }
                state.licenses = .init(uniqueElements: licenses)
                return .none
            }
        }
    }
}
