//
//  AdHocApp.swift
//  AdHoc
//
//  Created by Yuya Oka on 2023/10/13.
//

import Dependencies
import DependenciesLive
import FirebaseAnalytics
import class FirebaseCore.FirebaseApp
import class GoogleMobileAds.MobileAds
import class RevenueCat.Purchases
import SSLCertificateCheckKit
import SwiftUI

@main
struct AdHocApp: App {
  // MARK: - Body
  var body: some Scene {
    WindowGroup {
      prepareDependencies {
        $0.adClient = .google
        $0.adUnitID = .develop
        $0.consentInformation = .google
        $0.rewardedInterstitialAd = .google
        $0.revenueCat = .revenueCat

        return RootPage(
          store: .init(
            initialState: RootReducer.State(),
            reducer: {
              RootReducer()
            },
          ),
        )
      }
    }
  }

  // MARK: - Initialize
  init() {
    FirebaseApp.configure()
    Task {
      _ = await MobileAds.shared.start()
    }
    Purchases.configure(withAPIKey: "appl_tCBoNHVYLrNNHLlPSrarLoDORLz")
    Analytics.setUserID(Purchases.shared.appUserID)
  }
}
