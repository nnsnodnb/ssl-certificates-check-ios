//
//  ProductionApp.swift
//  Production
//
//  Created by Yuya Oka on 2023/10/12.
//

import SSLCertificateCheckPackage
import SwiftUI

@main
struct ProductionApp: App {
    // MARK: - Properties
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            RootPage()
        }
    }
}
