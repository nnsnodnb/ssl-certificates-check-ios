//
//  LicenseClient.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/08/27.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct LicenseClient: Sendable {
  // MARK: - Properties
  public var fetchLicenses: @Sendable () async throws -> [LicensesPlugin.License]
}

// MARK: - DependencyKey
extension LicenseClient: DependencyKey {
  public static let liveValue: LicenseClient = .init(
    fetchLicenses: { LicensesPlugin.licenses },
  )
  public static let testValue: LicenseClient = .init(
    fetchLicenses: { LicensesPlugin.licenses },
  )
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
