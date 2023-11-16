//
//  LicenseListReducer.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import CasePaths
import ComposableArchitecture
import Foundation
import Logger

@Reducer
package struct LicenseListReducer {
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
        case fetchLicensesResponse(Result<[License], Error>)

        // MARK: - Error
        @CasePathable
        package enum Error: Swift.Error {
            case fetchLicenses
        }
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
                return .run(
                    operation: { send in
                        let licenses = try await license.fetchLicenses()
                        await send(.fetchLicensesResponse(.success(licenses)))
                    },
                    catch: { error, send in
                        await send(.fetchLicensesResponse(.failure(.fetchLicenses)))
                        Logger.error("\(error)")
                    }
                )
            case let .fetchLicensesResponse(.success(licenses)):
                state.licenses = .init(uniqueElements: licenses)
                return .none
            case .fetchLicensesResponse(.failure):
                return .none
            }
        }
    }
}
