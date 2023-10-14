//
//  DependencyValues+Extension.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import Dependencies
import Foundation

// MARK: - BundleClient
package extension DependencyValues {
    var bundle: BundleClient {
        get { self[BundleClient.self] }
        set { self[BundleClient.self] = newValue }
    }
}
