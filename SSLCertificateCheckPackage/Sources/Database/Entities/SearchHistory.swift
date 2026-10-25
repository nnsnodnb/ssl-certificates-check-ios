//
//  SearchHistory.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/10/25.
//

import Foundation
import MemberwiseInit
import X509Parser

@MemberwiseInit(.public)
public struct SearchHistory: Hashable, Sendable {
  // MARK: - Properties
  public let id: UUID
  public let domain: String
  public let x509: X509
  public let createdAt: Date
}
