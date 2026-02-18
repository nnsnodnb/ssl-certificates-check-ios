//
//  ProductionApp.swift
//  Production
//
//  Created by Yuya Oka on 2023/10/12.
//

import Application
import SwiftUI

@main
struct ProductionApp: App {
    // MARK: - Properties
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var delegate

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
}
