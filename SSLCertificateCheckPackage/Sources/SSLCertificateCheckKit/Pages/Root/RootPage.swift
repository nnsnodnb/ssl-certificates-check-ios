//
//  RootPage.swift
//
//
//  Created by Yuya Oka on 2023/10/12.
//

import ComposableArchitecture
import Dependencies
import DependenciesInterfaces
import MemberwiseInit
import SwiftUI
import XCTestDynamicOverlay

@MemberwiseInit(.public)
public struct RootPage: View {
  // MARK: - Properties
  @Init(.public)
  public let store: StoreOf<RootReducer>

  // MARK: - Dependencies
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
    if let store = store.scope(\.search, action: \.search) {
      SearchPage(store: store)
    } else {
      checkSubscriptionPage
    }
  }

  @ViewBuilder private var checkSubscriptionPage: some View {
    if let store = store.scope(\.checkSubscription, action: \.checkSubscription) {
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
    if let store = store.scope(\.consent, action: \.consent) {
      ConsentPage(store: store)
    }
  }
}

struct RootPage_Previews: PreviewProvider {
  static var previews: some View {
    RootPage(
      store: .init(
        initialState: RootReducer.State(),
        reducer: {
          RootReducer()
        },
        withDependencies: {
          $0.adUnitID.requestStartRewardAdUnitID = { "ca-app-pub-3940256099942544/6978759866" }
          $0.adUnitID.searchPageBottomBannerAdUnitID = { "ca-app-pub-3940256099942544/2435281174" }
        },
      ),
    )
  }
}
