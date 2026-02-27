//
//  DevelopApp.swift
//  Develop
//
//  Created by Yuya Oka on 2023/10/12.
//

import Application
import class FirebaseCore.FirebaseApp
import class GoogleMobileAds.MobileAds
import class RevenueCat.Purchases
import SwiftUI

@main
struct DevelopApp: App {
  // MARK: - Body
  var body: some Scene {
    WindowGroup {
      RootPage(
        dependency: .init(
          requestStartRewardAdUnitID: "ca-app-pub-3940256099942544/1712485313",
          searchPageBottomBannerAdUnitID: "ca-app-pub-3940256099942544/2435281174",
        )
      )
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
      _ = try await Purchases.shared.logIn("$RCAnonymousID:ccff33d798344877aa1f363be90eb38f")
    }
  }
}
