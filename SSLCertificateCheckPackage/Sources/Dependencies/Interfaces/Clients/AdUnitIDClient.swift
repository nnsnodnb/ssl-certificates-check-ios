//
//  AdUnitIDClient.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/17.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct AdUnitIDClient: Sendable {
  // MARK: - Properties
  public var requestStartRewardAdUnitID: @Sendable () throws -> String
  public var searchPageBottomBannerAdUnitID: @Sendable () throws -> String
}

// MARK: - DependencyKey
extension AdUnitIDClient: DependencyKey {
  public static let liveValue: Self = .init(
    requestStartRewardAdUnitID: { throw Error.mustSetAdIDFromRootPage },
    searchPageBottomBannerAdUnitID: { throw Error.mustSetAdIDFromRootPage },
  )
}

// MARK: - Error
public extension AdUnitIDClient {
  enum Error: Swift.Error {
    case mustSetAdIDFromRootPage
  }
}

// MARK: - DependencyValues
public extension DependencyValues {
  var adUnitID: AdUnitIDClient {
    get {
      self[AdUnitIDClient.self]
    }
    set {
      self[AdUnitIDClient.self] = newValue
    }
  }
}
