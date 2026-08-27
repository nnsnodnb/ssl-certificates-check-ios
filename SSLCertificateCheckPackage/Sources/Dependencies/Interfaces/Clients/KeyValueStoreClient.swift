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
public struct KeyValueStoreClient: Sendable {
  // MARK: - Properties
  // swiftlint:disable identifier_name
  public var getWasRequestReviewFinishFirstSearchExperience: @Sendable () async throws -> Bool
  public var setWasRequestReviewFinishFirstSearchExperience: @Sendable (Bool) async throws -> Void
  // swiftlint:enable identifier_name
}

// MARK: - Key
public extension KeyValueStoreClient {
  enum Key: String, CustomDebugStringConvertible {
    // swiftlint:disable identifier_name
    case wasRequestReviewFinishFirstSearchExperience
    // swiftlint:enable identifier_name

    // MARK: - Properties
    public var debugDescription: String {
      switch self {
      case .wasRequestReviewFinishFirstSearchExperience:
        return "初めての検索詳細を見た経験によるAppReviewの有無"
      }
    }
  }
}

// MARK: - DependencyKey
extension KeyValueStoreClient: DependencyKey {
  public static let liveValue: KeyValueStoreClient = .init(
    getWasRequestReviewFinishFirstSearchExperience: {
      await AppStorageActor.shared.getWasRequestReviewFinishFirstSearchExperience()
    },
    setWasRequestReviewFinishFirstSearchExperience: {
      await AppStorageActor.shared.setWasRequestReviewFinishFirstSearchExperience(value: $0)
    }
  )
  public static let testValue: KeyValueStoreClient = .init()
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

// MARK: - DependencyValues
public extension DependencyValues {
  var keyValueStore: KeyValueStoreClient {
    get {
      self[KeyValueStoreClient.self]
    }
    set {
      self[KeyValueStoreClient.self] = newValue
    }
  }
}
