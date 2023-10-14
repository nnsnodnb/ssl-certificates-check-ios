//
//  ApplicationClient.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import Dependencies
import Foundation
import UIKit
import XCTestDynamicOverlay

package struct ApplicationClient: Sendable {
    // MARK: - Properties
    package var open: @Sendable (URL) async -> Bool
}

// MARK: - DependencyKey
extension ApplicationClient: DependencyKey {
    package static let liveValue: ApplicationClient = .init(
        open: { @MainActor in await UIApplication.shared.open($0) }
    )
    package static let testValue: ApplicationClient = .init(
        open: unimplemented("\(Self.self).open")
    )
}
