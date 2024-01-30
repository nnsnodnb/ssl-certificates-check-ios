//
//  BundleClient.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
package struct BundleClient {
    // MARK: - Properties
    var shortVersionString: @Sendable () -> String = { "" }
}

// MARK: - DependencyKey
extension BundleClient: DependencyKey {
    package static let liveValue: BundleClient = .init(
        shortVersionString: {
            Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        }
    )
    package static var testValue: BundleClient = .init()
}
