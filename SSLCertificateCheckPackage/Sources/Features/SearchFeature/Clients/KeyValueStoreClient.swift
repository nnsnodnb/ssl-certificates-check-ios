//
//  KeyValueStoreClient.swift
//
//
//  Created by Yuya Oka on 2023/10/21.
//

import Dependencies
import Foundation
import XCTestDynamicOverlay

package struct KeyValueStoreClient {
    // MARK: - Properties
    var bool: @Sendable (Key) async -> Bool
    var setBool: @Sendable (Bool, Key) async -> Void
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
        bool: { await UserDefaultsActor.shared.bool(forKey: $0) },
        setBool: { await UserDefaultsActor.shared.set(value: $0, forKey: $1) }
    )

    package static let testValue: KeyValueStoreClient = .init(
        bool: unimplemented("\(Self.self).bool"),
        setBool: unimplemented("\(Self.self).set")
    )
}

// MARK: - UserDefaultsActor
private extension KeyValueStoreClient {
    final actor UserDefaultsActor: GlobalActor {
        // MARK: - Properties
        static let shared: UserDefaultsActor = .init()
        static let testValue: UserDefaultsActor = .init(userDefaults: .init(suiteName: UUID().uuidString)!)

        private let userDefaults: UserDefaults

        // MARK: - Initialize
        private init(userDefaults: UserDefaults = .standard) {
            self.userDefaults = userDefaults
        }

        func bool(forKey key: Key) -> Bool {
            userDefaults.bool(forKey: key.rawValue)
        }

        func set(value: Bool, forKey key: Key) {
            userDefaults.set(value, forKey: key.rawValue)
        }
    }
}
