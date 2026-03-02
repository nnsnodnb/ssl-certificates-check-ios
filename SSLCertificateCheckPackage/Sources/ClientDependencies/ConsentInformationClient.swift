//
//  ConsentInformationClient.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/17.
//

import Dependencies
import DependenciesMacros
import Foundation
import UserMessagingPlatform

@DependencyClient
package struct ConsentInformationClient: Sendable {
  package var requestConsent: @Sendable () async throws -> Bool
  package var load: @Sendable () async throws -> Void
  package var loadAndPresentIfRequired: @Sendable () async throws -> Void
  package var visiblePrivacyOptionsRequirements: @Sendable () -> Bool = { false }
  package var presentPrivacyOptions: @Sendable () async throws -> Void
}

// MARK: - DependencyKey
extension ConsentInformationClient: DependencyKey {
  package static let liveValue: ConsentInformationClient = .init(
    requestConsent: {
      let parameters = RequestParameters()
#if DEBUG
      let debugSettings = DebugSettings()
      debugSettings.geography = .EEA
      parameters.debugSettings = debugSettings
#endif

      try await ConsentInformation.shared.requestConsentInfoUpdate(with: parameters)
      guard ConsentInformation.shared.consentStatus == .required else { return false }
      let status = ConsentInformation.shared.formStatus == .available
      return status
    },
    load: { @MainActor in
      try await ConsentForm.load()
    },
    loadAndPresentIfRequired: { @MainActor in
      try await ConsentForm.loadAndPresentIfRequired(from: nil)
    },
    visiblePrivacyOptionsRequirements: {
      ConsentInformation.shared.privacyOptionsRequirementStatus == .required
    },
    presentPrivacyOptions: { @MainActor in
      let parameters = RequestParameters()
#if DEBUG
      let debugSettings = DebugSettings()
      debugSettings.geography = .EEA
      parameters.debugSettings = debugSettings
#endif

      try await ConsentInformation.shared.requestConsentInfoUpdate(with: parameters)
      guard ConsentInformation.shared.consentStatus == .obtained else { return }
      try await ConsentForm.presentPrivacyOptionsForm(from: nil)
    },
  )
}

// MARK: - DependencyValues
package extension DependencyValues {
  var consentInformation: ConsentInformationClient {
    get {
      self[ConsentInformationClient.self]
    }
    set {
      self[ConsentInformationClient.self] = newValue
    }
  }
}
