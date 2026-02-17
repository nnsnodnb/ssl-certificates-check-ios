//
//  AppDelegate.swift
//  Develop
//
//  Created by Yuya Oka on 2023/10/13.
//

import class FirebaseCore.FirebaseApp
import class GoogleMobileAds.MobileAds
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        Task {
            _ = await MobileAds.shared.start()
        }
        return true
    }
}
