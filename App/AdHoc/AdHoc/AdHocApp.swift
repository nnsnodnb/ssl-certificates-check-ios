//
//  AdHocApp.swift
//  AdHoc
//
//  Created by Yuya Oka on 2023/10/13.
//

import Application
import SwiftUI

@main
struct AdHocApp: App {
    // MARK: - Properties
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var delegate

    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            RootPage(
                rootDependency: .init(
                    requestStartRewardAdUnitID: "ca-app-pub-3940256099942544/1712485313",
                )
            )
        }
    }
}
