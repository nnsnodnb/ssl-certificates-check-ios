//
//  LicenseClient.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import Dependencies
import Foundation
import XCTestDynamicOverlay

package struct LicenseClient {
    // MARK: - Properties
    package var fetchLicenses: @Sendable () -> [License]
}

// MARK: - DependencyKey
extension LicenseClient: DependencyKey {
    package static let liveValue: LicenseClient = .init(
        fetchLicenses: {
            LicensesPlugin.licenses.map { License(id: $0.id, name: $0.name, licenseText: $0.licenseText) }
        }
    )
    package static let testValue: LicenseClient = .init(
        fetchLicenses: unimplemented("\(Self.self).fetchLicenses")
    )
}
