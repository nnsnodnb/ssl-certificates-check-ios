//
//  KeyValueStoreClient.swift
//
//
//  Created by Yuya Oka on 2023/10/21.
//

import Dependencies
import DependenciesMacros
import Foundation
import SwiftUI

@DependencyClient
package struct KeyValueStoreClient {
    // MARK: - Properties
    // swiftlint:disable identifier_name
    var getWasRequestReviewFinishFirstSearchExperience: @Sendable () async throws -> Bool
    var setWasRequestReviewFinishFirstSearchExperience: @Sendable (Bool) async throws -> Void
    // swiftlint:enable identifier_name
}

// MARK: - Key
package extension KeyValueStoreClient {
    enum Key: String, CustomDebugStringConvertible {
        // swiftlint:disable identifier_name
        case wasRequestReviewFinishFirstSearchExperience
        // swiftlint:enable identifier_name

        // MARK: - Properties
        package var debugDescription: String {
            switch self {
            case .wasRequestReviewFinishFirstSearchExperience:
                return "初めての検索詳細を見た経験によるAppReviewの有無"
            }
        }
    }
}

// MARK: - DependencyKey
extension KeyValueStoreClient: DependencyKey {
    package static let liveValue: KeyValueStoreClient = .init(
        getWasRequestReviewFinishFirstSearchExperience: {
            AppStorageActor.shared.getWasRequestReviewFinishFirstSearchExperience()
        },
        setWasRequestReviewFinishFirstSearchExperience: {
            AppStorageActor.shared.setWasRequestReviewFinishFirstSearchExperience(value: $0)
        }
    )
    package static let testValue: KeyValueStoreClient = .init()
}

// MARK: - UserDefaultsActor
private extension KeyValueStoreClient {
    final actor AppStorageActor: GlobalActor {
        // MARK: - Properties
        static let shared: AppStorageActor = .init()
        static let testValue: AppStorageActor = .init()

        // swiftlint:disable identifier_name
        @AppStorage(Key.wasRequestReviewFinishFirstSearchExperience.rawValue)
        private var wasRequestReviewFinishFirstSearchExperience = false
        // swiftlint:enable identifier_name

        func getWasRequestReviewFinishFirstSearchExperience() -> Bool {
            return wasRequestReviewFinishFirstSearchExperience
        }

        func setWasRequestReviewFinishFirstSearchExperience(value: Bool) {
            wasRequestReviewFinishFirstSearchExperience = value
        }
    }
}
