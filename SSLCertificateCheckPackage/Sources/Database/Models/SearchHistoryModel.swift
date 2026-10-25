//
//  SearchHistoryModel.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/10/25.
//

import Foundation
import SwiftData
import X509Parser

@Model
public class SearchHistoryModel: Hashable {
  // MARK: - Properties
  @Attribute(.unique)
  public var id: UUID
  public var domain: String
  public var x509Data: Data
  public var createdAt: Date

  // MARK: - Initialize
  public init(id: UUID, domain: String, x509: [X509], createdAt: Date = .now) throws {
    self.id = id
    self.domain = domain
    self.x509Data = try JSONEncoder().encode(x509)
    self.createdAt = createdAt
  }

  public init(id: UUID, domain: String, x509Data: Data, createdAt: Date = .now) {
    self.id = id
    self.domain = domain
    self.x509Data = x509Data
    self.createdAt = createdAt
  }

  public func decodeX509() throws -> [X509] {
    try JSONDecoder().decode([X509].self, from: x509Data)
  }
}
