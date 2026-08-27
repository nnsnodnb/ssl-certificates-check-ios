//
//  DevelopApp.swift
//  Develop
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
struct DevelopApp: App {
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
      MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [
        "F8BB1C28-BAE8-11D6-9C31-00039315CD46",
      ]
    }
    Purchases.configure(withAPIKey: "appl_tCBoNHVYLrNNHLlPSrarLoDORLz")
    Task {
      let userID = "$RCAnonymousID:ccff33d798344877aa1f363be90eb38f"
      _ = try await Purchases.shared.logIn(userID)
    }
    Analytics.setUserID(Purchases.shared.appUserID)
  }
}
