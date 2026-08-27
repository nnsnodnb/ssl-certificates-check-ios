//
//  ConsentInformationClient.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/08/27.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct ConsentInformationClient: Sendable {
  public var requestConsent: @Sendable () async throws -> Bool
  public var load: @Sendable () async throws -> Void
  public var loadAndPresentIfRequired: @Sendable () async throws -> Void
  public var visiblePrivacyOptionsRequirements: @Sendable () -> Bool = { false }
  public var presentPrivacyOptions: @Sendable () async throws -> Void
}

// MARK: - DependencyKey
extension ConsentInformationClient: DependencyKey {
  public static let liveValue: ConsentInformationClient = .init(
    requestConsent: { false },
    load: {},
    loadAndPresentIfRequired: {},
    visiblePrivacyOptionsRequirements: { false },
    presentPrivacyOptions: {},
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var consentInformation: ConsentInformationClient {
    get {
      self[ConsentInformationClient.self]
    }
    set {
      self[ConsentInformationClient.self] = newValue
    }
  }
}
