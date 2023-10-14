//
//  DependencyValues+Extensions.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import Dependencies
import XCTestDynamicOverlay

// MARK: - BundleClient
package extension DependencyValues {
    var application: ApplicationClient {
        get { self[ApplicationClient.self] }
        set { self[ApplicationClient.self] = newValue }
    }
}
