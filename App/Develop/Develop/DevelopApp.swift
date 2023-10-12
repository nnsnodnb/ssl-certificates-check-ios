//
//  DevelopApp.swift
//  Develop
//
//  Created by Yuya Oka on 2023/10/12.
//

import SSLCertificateCheckPackage
import SwiftUI

@main
struct DevelopApp: App {
    // MARK: - Properties
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            RootPage()
        }
    }
}
