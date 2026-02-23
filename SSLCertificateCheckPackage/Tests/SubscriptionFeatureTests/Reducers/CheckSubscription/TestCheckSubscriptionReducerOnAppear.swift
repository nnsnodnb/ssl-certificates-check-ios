//
//  TestCheckSubscriptionReducerOnAppear.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/21.
//

import Combine
import ComposableArchitecture
import DependenciesTestSupport
@testable import SubscriptionFeature
import Testing

@MainActor
struct TestCheckSubscriptionReducerOnAppear {
    @Test(
        .dependencies {
            $0.revenueCat.isPremiumActiveStream = {
                AsyncStream {
                    $0.yield(true)
                    $0.finish()
                }
            }
        }
    )
    func testGetIsActive() async throws {
        let store = TestStore(
            initialState: CheckSubscriptionReducer.State(),
            reducer: {
                CheckSubscriptionReducer()
            },
        )

        await store.send(.onAppear)
        await store.receive(\.gotIsPremiumActive) {
            $0.$isPremiumActive.withLock { $0 = true }
            $0.wasSendCompleted = true
        }
        await store.receive(\.delegate.completed)
    }

    @Test(
        .dependencies {
            $0.revenueCat.isPremiumActiveStream = {
                AsyncStream {
                    $0.yield(false)
                    $0.finish()
                }
            }
        }
    )
    func testGetIsNotActive() async throws {
        let store = TestStore(
            initialState: CheckSubscriptionReducer.State(),
            reducer: {
                CheckSubscriptionReducer()
            },
        )

        await store.send(.onAppear)
        await store.receive(\.gotIsPremiumActive) {
            $0.wasSendCompleted = true
        }
        await store.receive(\.delegate.completed)
    }
}
