//
//  DependencyValues+Extensions.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import Dependencies
import Foundation

// MARK: - LicenseClient
package extension DependencyValues {
    var license: LicenseClient {
        get { self[LicenseClient.self] }
        set { self[LicenseClient.self] = newValue }
    }
}
