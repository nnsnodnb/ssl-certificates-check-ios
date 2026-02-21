//
//  AppDelegate.swift
//  Develop
//
//  Created by Yuya Oka on 2023/10/13.
//

import class FirebaseCore.FirebaseApp
import class GoogleMobileAds.MobileAds
import class RevenueCat.Purchases
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        Task {
            _ = await MobileAds.shared.start()
            MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [
                "F8BB1C28-BAE8-11D6-9C31-00039315CD46",
            ]
        }
        Purchases.configure(withAPIKey: "appl_tCBoNHVYLrNNHLlPSrarLoDORLz")
        return true
    }
}
