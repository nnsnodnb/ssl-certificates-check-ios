//
//  PasteboardClient.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/11/15.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct PasteboardClient: Sendable {
  public var setString: @Sendable (String) async throws -> Void
}

// MARK: - DependencyKey
extension PasteboardClient: DependencyKey {
  public static let liveValue: PasteboardClient = .init(
    setString: { _ in },
  )
  public static let previewValue: PasteboardClient = .init(
    setString: { _ in },
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var pasteboard: PasteboardClient {
    get {
      self[PasteboardClient.self]
    }
    set {
      self[PasteboardClient.self] = newValue
    }
  }
}
