//
//  RewardedAdClientswift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/17.
//

import Dependencies
import DependenciesMacros
import Foundation
import GoogleMobileAds

@DependencyClient
package struct RewardedAdClient: Sendable {
    package var show: @Sendable () async throws -> Int
}

// MARK: - DependencyKey
extension RewardedAdClient: DependencyKey {
    package static let liveValue: RewardedAdClient = .init(
        show: { @MainActor in
            @Dependency(\.adUnitID.requestStartRewardAdUnitID)
            var adUnitID

            let rewardedAd = try await RewardedAd.load(with: try adUnitID(), request: .init())
            return try await Implementation.shared.show(rewardedAd: rewardedAd)
        },
    )
}

// MARK: - Implementation
private extension RewardedAdClient {
    final actor Implementation: GlobalActor {
        // MARK: - Properties
        static let shared: Implementation = .init()

        private let delegate: LockIsolated<Delegate?> = .init(nil)

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
                guard let rewardedAd = ad as? RewardedAd else { return }
                earnRewarded(rewardedAd.adReward.amount.intValue)
            }
        }

        @MainActor
        func show(rewardedAd: any RewardedAdProtocol) async throws -> Int {
            try rewardedAd.canPresent()
            return await withUnsafeContinuation { [weak self] continuation in
                let delegate = Delegate { [weak self] amount in
                    continuation.resume(returning: amount)
                    self?.delegate.setValue(nil)
                }
                self?.delegate.setValue(delegate)
                rewardedAd.present(delegate: delegate)
            }
        }
    }
}

// MARK: - DependencyValues
package extension DependencyValues {
    var rewardedAd: RewardedAdClient {
        get {
            self[RewardedAdClient.self]
        }
        set {
            self[RewardedAdClient.self] = newValue
        }
    }
}
