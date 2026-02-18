//
//  DevelopApp.swift
//  Develop
//
//  Created by Yuya Oka on 2023/10/12.
//

import Application
import SwiftUI

@main
struct DevelopApp: App {
    // MARK: - Properties
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var delegate

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
}
