//
//  InfoReducer.swift
//
//
//  Created by Yuya Oka on 2023/10/13.
//

import ComposableArchitecture
import Foundation
import LicenseFeature

package struct InfoReducer: Reducer {
    // MARK: - State
    package struct State: Equatable {
        // MARK: - Properties
        var licenseList: LicenseListReducer.State?
        var destinations: [Destination]

        // MARK: - Destination
        package enum Destination {
            case licenseList
        }

        // MARK: - Initialize
        package init(licenseList: LicenseListReducer.State? = nil, destinations: [Destination] = []) {
            self.licenseList = licenseList
            self.destinations = destinations
        }
    }

    // MARK: - Action
    package enum Action {
        case dismiss
        case pushLicenseList
        case navigationPathChanged([State.Destination])
        case licenseList(LicenseListReducer.Action)
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
            case .pushLicenseList:
                state.licenseList = .init()
                state.destinations.append(.licenseList)
                return .none
            case let .navigationPathChanged(destinations):
                state.destinations = destinations
                return .none
            case .licenseList:
                return .none
            }
        }
        .ifLet(\.licenseList, action: /Action.licenseList) {
            LicenseListReducer()
        }
    }
}
