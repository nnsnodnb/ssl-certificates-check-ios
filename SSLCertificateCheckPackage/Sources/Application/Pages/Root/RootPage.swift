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
import MemberwiseInit
import SearchFeature
import SubscriptionFeature
import SwiftUI
import XCTestDynamicOverlay

@MemberwiseInit(.public)
public struct RootDependency: Sendable {
  // MARK: - Properties
  public let requestStartRewardAdUnitID: String
  public let searchPageBottomBannerAdUnitID: String
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

  @ViewBuilder private var searchPage: some View {
    if let store = store.scope(state: \.search, action: \.search) {
      SearchPage(store: store)
    } else {
      checkSubscriptionPage
    }
  }

  @ViewBuilder private var checkSubscriptionPage: some View {
    if let store = store.scope(state: \.checkSubscription, action: \.checkSubscription) {
      ZStack {
        CheckSubscriptionPage(store: store)
        consentPage
      }
    } else {
      Color(UIColor.systemBackground.withAlphaComponent(0.000001))
        .ignoresSafeArea(.all)
        .onAppear {
          store.send(.showCheckSubscription)
        }
    }
  }

  @ViewBuilder private var consentPage: some View {
    if let store = store.scope(state: \.consent, action: \.consent) {
      ConsentPage(store: store)
    }
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

struct RootPage_Previews: PreviewProvider {
  static var previews: some View {
    RootPage(
      dependency: .init(
        requestStartRewardAdUnitID: "ca-app-pub-3940256099942544/6978759866",
        searchPageBottomBannerAdUnitID: "ca-app-pub-3940256099942544/2435281174",
      )
    )
  }
}
