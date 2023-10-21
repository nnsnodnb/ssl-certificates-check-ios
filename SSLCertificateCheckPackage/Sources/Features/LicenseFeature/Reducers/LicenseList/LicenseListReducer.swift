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
    package enum Action: Equatable {
        case fetchLicenses
        case fetchLicensesResponse(TaskResult<[License]>)
    }

    // MARK: - Properties
    @Dependency(\.license)
    private var license

    // MARK: - Initialize
    package init() {
    }

    // MARK: - Body
    package var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchLicenses:
                return .run { send in
                    let licenses = try await license.fetchLicenses()
                    await send(.fetchLicensesResponse(.success(licenses)))
                }
            case let .fetchLicensesResponse(.success(licenses)):
                state.licenses = .init(uniqueElements: licenses)
                return .none
            case .fetchLicensesResponse(.failure):
                return .none
            }
        }
    }
}
