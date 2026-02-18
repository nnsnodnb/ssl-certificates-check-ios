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
import SwiftUI
import XCTestDynamicOverlay

public struct RootDependency: Sendable {
    // MARK: - Properties
    public let requestStartRewardAdUnitID: String

    // MARK: - Initialize
    public init(requestStartRewardAdUnitID: String) {
        self.requestStartRewardAdUnitID = requestStartRewardAdUnitID
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
                        store.send(.showConsent)
                    }
            }
        )
    }

    // MARK: - Initialize
    public init(dependency: RootDependency) {
        self.store = .init(
            initialState: RootReducer.State(
                requestStartRewardAdUnitID: dependency.requestStartRewardAdUnitID,
            ),
            reducer: {
                RootReducer()
            },
            withDependencies: {
                $0.adUnitID = .init(
                    requestStartRewardAdUnitID: { dependency.requestStartRewardAdUnitID },
                )
            },
        )
    }
}

#Preview {
    RootPage(
        dependency: .init(
            requestStartRewardAdUnitID: "ca-app-pub-3940256099942544/1712485313",
        )
    )
}
