//
//  ApplicationClient.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import Dependencies
import DependenciesMacros
import Foundation
import UIKit

@DependencyClient
package struct ApplicationClient: Sendable {
    // MARK: - Properties
    package var open: @Sendable (URL) async throws -> Bool
}

// MARK: - DependencyKey
extension ApplicationClient: DependencyKey {
    package static let liveValue: ApplicationClient = .init(
        open: { @MainActor in await UIApplication.shared.open($0) }
    )
    package static let testValue: ApplicationClient = .init()
}

// MARK: - DependencyValues
package extension DependencyValues {
    var application: ApplicationClient {
        get {
            self[ApplicationClient.self]
        }
        set {
            self[ApplicationClient.self] = newValue
        }
    }
}
