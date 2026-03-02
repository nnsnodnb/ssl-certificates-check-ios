//
//  RewardedInterstitialAdClient
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/17.
//

import Dependencies
import DependenciesMacros
import Foundation
import GoogleMobileAds

@DependencyClient
package struct RewardedInterstitialAdClient: Sendable {
  package var load: @Sendable () async throws -> Void
  package var show: @Sendable () async throws -> Int

  // MARK: - Error
  package enum Error: Swift.Error {
    case notReady
    case interruption
  }
}

// MARK: - DependencyKey
extension RewardedInterstitialAdClient: DependencyKey {
  package static let liveValue: Self = .init(
    load: {
      try await Implementation.shared.load()
    },
    show: {
      return try await Implementation.shared.show()
    },
  )
}

// MARK: - Implementation
private extension RewardedInterstitialAdClient {
  final actor Implementation: GlobalActor {
    // MARK: - State
    private enum State {
      case idle
      case loading
      case ready(any RewardedInterstitialAdProtocol)
      case failed
    }

    // MARK: - Properties
    static let shared: Implementation = .init()

    private let delegate: LockIsolated<Delegate?> = .init(nil)
    private let state: LockIsolated<State> = .init(.idle)
    private let earnedReward: LockIsolated<Bool> = .init(false)

    @Dependency(\.adUnitID.requestStartRewardAdUnitID)
    private var adUnitID
    @Dependency(\.continuousClock)
    private var continuousClock

    // MARK: - Delegate
    final class Delegate: NSObject, FullScreenContentDelegate, Sendable {
      // MARK: - Properties
      let earnRewarded: @Sendable (Int) -> Void

      // MARK: - Initialize
      init(earnRewarded: @Sendable @escaping (Int) -> Void) {
        self.earnRewarded = earnRewarded
      }

      // MARK: - FullScreenContentDelegate
      // swiftlint:disable:next identifier_name
      func adDidDismissFullScreenContent(_ ad: any FullScreenPresentingAd) {
        guard let rewardedAd = ad as? RewardedInterstitialAd else { return }
        earnRewarded(rewardedAd.adReward.amount.intValue)
      }
    }

    func load() async throws {
      var retryCount = 0
      while retryCount < 5 {
        switch state.value {
        case .idle:
          state.setValue(.loading)
          do {
            let rewardedAd = try await RewardedInterstitialAd.load(with: try adUnitID(), request: .init())
            state.setValue(.ready(rewardedAd))
            return
          } catch {
            retryCount += 1
            state.setValue(.failed)
            try? await continuousClock.sleep(for: .milliseconds(500))
            state.setValue(.idle)
          }
        case .loading, .ready:
          return
        case .failed:
          state.setValue(.idle)
        }
      }
    }

    @MainActor
    func show() async throws -> Int {
      if case let .ready(rewardedAd) = state.value {
        try rewardedAd.canPresent()
        return try await withCheckedThrowingContinuation { [weak self] continuation in
          let delegate = Delegate { [weak self] amount in
            if self?.earnedReward.value == true {
              continuation.resume(returning: amount)
            } else {
              self?.state.setValue(.idle)
              continuation.resume(throwing: Error.interruption)
            }
            self?.delegate.setValue(nil)
          }
          self?.delegate.setValue(delegate)
          rewardedAd.present(delegate: delegate) { [weak self] in
            self?.state.setValue(.idle)
            self?.earnedReward.setValue(true)
          }
        }
      }
      try await load()
      return try await show()
    }
  }
}

// MARK: - DependencyValues
package extension DependencyValues {
  var rewardedInterstitialAd: RewardedInterstitialAdClient {
    get {
      self[RewardedInterstitialAdClient.self]
    }
    set {
      self[RewardedInterstitialAdClient.self] = newValue
    }
  }
}
