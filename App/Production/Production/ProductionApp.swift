//
//  ProductionApp.swift
//  Production
//
//  Created by Yuya Oka on 2023/10/12.
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
struct ProductionApp: App {
  // MARK: - Body
  var body: some Scene {
    WindowGroup {
      prepareDependencies {
        $0.adClient = .google
        $0.adUnitID = .production
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
