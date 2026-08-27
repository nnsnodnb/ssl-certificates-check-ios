//
//  RevenueCatClient.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/19.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct RevenueCatClient: Sendable {
  public var isPremiumActiveStream: @Sendable () async throws -> AsyncStream<Bool>
  public var isPremiumActive: @Sendable () async throws -> Bool
  public var buyMeACoffee: @Sendable () async throws -> Void

  // MARK: - Error
  public enum Error: Swift.Error {
    case internalError
    case userCancelled
    case purchaseError
  }
}

// MARK: - DependencyKey
extension RevenueCatClient: DependencyKey {
  public static let liveValue: RevenueCatClient = .init(
    isPremiumActiveStream: {
      AsyncStream<Bool> {
        $0.finish()
      }
    },
    isPremiumActive: { false },
    buyMeACoffee: {},
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var revenueCat: RevenueCatClient {
    get {
      self[RevenueCatClient.self]
    }
    set {
      self[RevenueCatClient.self] = newValue
    }
  }
}
