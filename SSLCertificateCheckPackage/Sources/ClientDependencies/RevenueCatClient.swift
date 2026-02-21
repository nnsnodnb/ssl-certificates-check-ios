//
//  RevenueCatClient.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/19.
//

import Dependencies
import DependenciesMacros
import Foundation
import RevenueCat

@DependencyClient
package struct RevenueCatClient: Sendable {
    package var isPremiumActiveStream: @Sendable () async throws -> AsyncStream<Bool>
    package var isPremiumActive: @Sendable () async throws -> Bool
}

// MARK: - DependencyKey
extension RevenueCatClient: DependencyKey {
    package static let liveValue: RevenueCatClient = .init(
        isPremiumActiveStream: {
            await Implementation.shared.stream()
        },
        isPremiumActive: {
            try await Implementation.shared.isPremiumActive()
        },
    )
}

// MARK: - Implementation
extension RevenueCatClient {
    final actor Implementation: GlobalActor {
        // MARK: - Properties
        static let shared = Implementation()

        private let continuation: LockIsolated<AsyncStream<Bool>.Continuation?> = .init(nil)
        private let _isPremiumActive: LockIsolated<Bool?> = .init(nil)

        // MARK: - Initialize
        init() {
            Task {
                await startListening()
            }
        }

        func stream() -> AsyncStream<Bool> {
            AsyncStream<Bool> { [weak self] continuation in
                guard let self else { return }
                self.continuation.setValue(continuation)
                guard let isPremiumActive = _isPremiumActive.value else { return }
                continuation.yield(isPremiumActive)
            }
        }

        func isPremiumActive() async throws -> Bool {
            if let isPremiumActive = _isPremiumActive.value {
                return isPremiumActive
            }
            let customerInfo = try await Purchases.shared.customerInfo()
            let isActive = customerInfo.entitlements.all["Premium"]?.isActive == true
            _isPremiumActive.setValue(isActive)
            return isActive
        }

        private func startListening() async {
            if let customerInfo = try? await Purchases.shared.customerInfo(fetchPolicy: .fetchCurrent) {
                applyCustomerInfo(customerInfo)
            }
            for try await customerInfo in Purchases.shared.customerInfoStream {
                applyCustomerInfo(customerInfo)
            }
        }

        private func applyCustomerInfo(_ customerInfo: CustomerInfo) {
            let isActive = customerInfo.entitlements.all["Premium"]?.isActive == true
            if _isPremiumActive.value != isActive {
                continuation.value?.yield(isActive)
                _isPremiumActive.setValue(isActive)
            }
        }
    }
}

// MARK: - DependencyValues
package extension DependencyValues {
    var revenueCat: RevenueCatClient {
        get {
            self[RevenueCatClient.self]
        }
        set {
            self[RevenueCatClient.self] = newValue
        }
    }
}
