//
//  AdHocApp.swift
//  AdHoc
//
//  Created by Yuya Oka on 2023/10/13.
//

import Application
import class FirebaseCore.FirebaseApp
import class GoogleMobileAds.MobileAds
import class RevenueCat.Purchases
import SwiftUI

@main
struct AdHocApp: App {
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
    }
    Purchases.configure(withAPIKey: "appl_tCBoNHVYLrNNHLlPSrarLoDORLz")
  }
}
