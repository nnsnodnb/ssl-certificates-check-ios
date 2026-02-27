//
//  ProductionApp.swift
//  Production
//
//  Created by Yuya Oka on 2023/10/12.
//

import Application
import class FirebaseCore.FirebaseApp
import class GoogleMobileAds.MobileAds
import class RevenueCat.Purchases
import SwiftUI

@main
struct ProductionApp: App {
  // MARK: - Body
  var body: some Scene {
    WindowGroup {
      RootPage(
        dependency: .init(
          requestStartRewardAdUnitID: "ca-app-pub-3417597686353524/1636683434",
          searchPageBottomBannerAdUnitID: "ca-app-pub-3417597686353524/1523645555",
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
