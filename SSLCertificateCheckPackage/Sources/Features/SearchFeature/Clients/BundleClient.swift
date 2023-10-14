//
//  BundleClient.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import Dependencies
import Foundation
import XCTestDynamicOverlay

package struct BundleClient {
    // MARK: - Properties
    package var shortVersionString: @Sendable () -> String
}

// MARK: - DependencyKey
extension BundleClient: DependencyKey {
    package static let liveValue: BundleClient = .init(
        shortVersionString: {
            Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        }
    )

    package static var testValue: BundleClient = .init(
        shortVersionString: unimplemented("\(Self.self).shortVersionString")
    )
}
