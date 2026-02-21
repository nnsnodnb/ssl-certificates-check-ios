//
//  CheckSubscriptionReducer.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/21.
//

import ClientDependencies
import ComposableArchitecture
import Dependencies
import Foundation

@Reducer
package struct CheckSubscriptionReducer: Sendable {
    // MARK: - State
    @ObservableState
    package struct State: Equatable, Sendable {
        @Shared(.inMemory("key_premium_subscription_is_active"))
        package var isPremiumActive = false

        // MARK: - Initialize
        package init(isPremiumActive: Bool = false) {
            self.$isPremiumActive.withLock { $0 = isPremiumActive }
        }
    }

    // MARK: - Action
    package enum Action {
        case onAppear
        case completed(Bool)
        case delegate(Delegate)

        @CasePathable
        package enum Delegate {
            case completed
        }
    }

    // MARK: - CancelID
    package enum CancelID {
        case isPremiumActiveStream
    }

    // MARK: - Dependency
    @Dependency(\.revenueCat)
    private var revenueCat

    // MARK: - Body
    package var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run(
                    operation: { send in
                        for await isActive in try await revenueCat.isPremiumActiveStream() {
                            await send(.completed(isActive))
                            break
                        }
                    },
                    catch: { _, send in
                        await send(.completed(false))
                    }
                )
                .cancellable(id: CancelID.isPremiumActiveStream, cancelInFlight: true)
            case let .completed(isActive):
                state.$isPremiumActive.withLock { $0 = isActive }
                return .merge(
                    .cancel(id: CancelID.isPremiumActiveStream),
                    .send(.delegate(.completed)),
                )
            case .delegate:
                return .none
            }
        }
    }

    // MARK: - Initialize
    package init() {
    }
}
