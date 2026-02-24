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
package struct AdUnitIDClient: Sendable {
  // MARK: - Properties
  package var requestStartRewardAdUnitID: @Sendable () throws -> String
  package var searchPageBottomBannerAdUnitID: @Sendable () throws -> String
}

// MARK: - DependencyKey
extension AdUnitIDClient: DependencyKey {
  package static let liveValue: Self = .init(
    requestStartRewardAdUnitID: { throw Error.mustSetAdIDFromRootPage },
    searchPageBottomBannerAdUnitID: { throw Error.mustSetAdIDFromRootPage },
  )
}

// MARK: - Error
package extension AdUnitIDClient {
  enum Error: Swift.Error {
    case mustSetAdIDFromRootPage
  }
}

// MARK: - DependencyValues
package extension DependencyValues {
  var adUnitID: AdUnitIDClient {
    get {
      self[AdUnitIDClient.self]
    }
    set {
      self[AdUnitIDClient.self] = newValue
    }
  }
}
