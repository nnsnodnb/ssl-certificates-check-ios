//
//  RootPage.swift
//
//
//  Created by Yuya Oka on 2023/10/12.
//

import ComposableArchitecture
import ConsentFeature
import Dependencies
import GoogleMobileAds
import SearchFeature
import SubscriptionFeature
import SwiftUI
import XCTestDynamicOverlay

public struct RootDependency: Sendable {
    // MARK: - Properties
    public let requestStartRewardAdUnitID: String
    public let searchPageBottomBannerAdUnitID: String

    // MARK: - Initialize
    public init(requestStartRewardAdUnitID: String, searchPageBottomBannerAdUnitID: String) {
        self.requestStartRewardAdUnitID = requestStartRewardAdUnitID
        self.searchPageBottomBannerAdUnitID = searchPageBottomBannerAdUnitID
    }
}

public struct RootPage: View {
    // MARK: - Properties
    private let store: StoreOf<RootReducer>

    @Dependency(\.consentInformation)
    private var consentInformation

    // MARK: - Body
    public var body: some View {
        if _XCTIsTesting {
            Text("Run Testing")
        } else {
            searchPage
        }
    }

    private var searchPage: some View {
        IfLetStore(
            store.scope(state: \.search, action: \.search),
            then: { store in
                SearchPage(store: store)
            },
            else: {
                checkSubscriptionPage
            }
        )
    }

    private var checkSubscriptionPage: some View {
        IfLetStore(
            store.scope(state: \.checkSubscription, action: \.checkSubscription),
            then: { store in
                CheckSubscriptionPage(store: store)
            },
            else: {
                consentPage
            }
        )
    }

    private var consentPage: some View {
        IfLetStore(
            store.scope(state: \.consent, action: \.consent),
            then: { store in
                ConsentPage(store: store)
            },
            else: {
                Color(UIColor.systemBackground.withAlphaComponent(0.000001))
                    .ignoresSafeArea(.all)
                    .onAppear {
                        store.send(.showCheckSubscription)
                    }
            }
        )
    }

    // MARK: - Initialize
    public init(dependency: RootDependency) {
        self.store = .init(
            initialState: RootReducer.State(
                requestStartRewardAdUnitID: dependency.requestStartRewardAdUnitID,
                searchPageBottomBannerAdUnitID: dependency.searchPageBottomBannerAdUnitID,
            ),
            reducer: {
                RootReducer()
            },
            withDependencies: {
                $0.adUnitID = .init(
                    requestStartRewardAdUnitID: { dependency.requestStartRewardAdUnitID },
                    searchPageBottomBannerAdUnitID: { dependency.searchPageBottomBannerAdUnitID },
                )
            },
        )
    }
}

#Preview {
    RootPage(
        dependency: .init(
            requestStartRewardAdUnitID: "ca-app-pub-3940256099942544/1712485313",
            searchPageBottomBannerAdUnitID: "ca-app-pub-3940256099942544/2435281174",
        )
    )
}
