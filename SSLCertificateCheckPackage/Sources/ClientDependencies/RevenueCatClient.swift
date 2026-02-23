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
    package var buyMeACoffee: @Sendable () async throws -> Void

    // MARK: - Error
    package enum Error: Swift.Error {
        case internalError
        case userCancelled
        case purchaseError
    }
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
        buyMeACoffee: {
            try await Implementation.shared.buyMeACoffee()
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

        func buyMeACoffee() async throws {
            let offerings = try await Purchases.shared.offerings()
            guard let package = offerings.current?.availablePackages.first(where: { $0.identifier == "$rc_gift" }) else {
                throw Error.internalError
            }
            let result = try await Purchases.shared.purchase(product: package.storeProduct)
            if result.userCancelled {
                throw Error.userCancelled
            }
            if result.transaction?.transactionIdentifier != nil {
                return
            }
            throw Error.purchaseError
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
