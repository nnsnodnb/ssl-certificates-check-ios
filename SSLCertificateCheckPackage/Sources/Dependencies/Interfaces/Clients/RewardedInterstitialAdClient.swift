//
//  RewardedInterstitialAdClient
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/17.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct RewardedInterstitialAdClient: Sendable {
  public var load: @Sendable () async throws -> Void
  public var show: @Sendable () async throws -> Int

  // MARK: - Error
  public enum Error: Swift.Error {
    case notReady
    case interruption
  }
}

// MARK: - DependencyKey
extension RewardedInterstitialAdClient: DependencyKey {
  public static let liveValue: Self = .init(
    load: {},
    show: { 0 },
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var rewardedInterstitialAd: RewardedInterstitialAdClient {
    get {
      self[RewardedInterstitialAdClient.self]
    }
    set {
      self[RewardedInterstitialAdClient.self] = newValue
    }
  }
}
