//
//  LicenseClient.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct LicenseClient: Sendable {
  // MARK: - Properties
  public var fetchLicenses: @Sendable () async throws -> [License]
}

// MARK: - DependencyKey
extension LicenseClient: DependencyKey {
  public static let liveValue: LicenseClient = .init(
    fetchLicenses: {
      LicensesPlugin.licenses.map { License(id: $0.id, name: $0.name, licenseText: $0.licenseText) }
    }
  )
  public static let testValue: LicenseClient = .init()
}

// MARK: - DependencyValues
public extension DependencyValues {
  var license: LicenseClient {
    get {
      self[LicenseClient.self]
    }
    set {
      self[LicenseClient.self] = newValue
    }
  }
}
