//
//  X509.swift
//
//
//  Created by Yuya Oka on 2023/10/27.
//

import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct X509: Hashable, Sendable, Identifiable {
  // MARK: - Properties
  public var id: String { serialNumber }

  public let version: String
  public let serialNumber: String
  public let notValidBefore: Date
  public let notValidAfter: Date
  public let issuer: DistinguishedNames
  public let subject: DistinguishedNames
  public let sha256Fingerprint: SHA256Fingerprint
}

// MARK: - DistinguishedNames
public extension X509 {
  struct DistinguishedNames: Hashable, Sendable {
    // MARK: - Properties
    public let commonName: String?
    public let organization: String?
    public let organizationalUnit: String?
    public let country: String?
    public let stateOrProvinceName: String?
    public let locality: String?
    public let streetAddress: String?
    public let domainComponent: String?
    public let emailAddress: String?
  }
}

// MARK: - SHA256Fingerprint
public extension X509 {
  @MemberwiseInit(.public)
  struct SHA256Fingerprint: Hashable, Sendable {
    // MARK: - Properties
    public let certificate: String
    public let publicKey: String
  }
}

#if DEBUG
public extension X509 {
  static var stub: Self {
    .init(
      version: "3",
      serialNumber: "16115816404043435608139631424403370993",
      notValidBefore: .init(),
      notValidAfter: .init(),
      issuer: .init(
        commonName: "DigiCert TLS RSA SHA256 2020 CA1",
        organization: "DigiCert Inc",
        organizationalUnit: "DigiCert Inc",
        country: "US",
        stateOrProvinceName: nil,
        locality: nil,
        streetAddress: nil,
        domainComponent: nil,
        emailAddress: nil,
      ),
      subject: .init(
        commonName: "www.example.org",
        organization: "Internet C2 Corporation for Assigned Names and Numbers",
        organizationalUnit: nil,
        country: "US",
        stateOrProvinceName: "California",
        locality: "Los Angeles",
        streetAddress: nil,
        domainComponent: nil,
        emailAddress: nil,
      ),
      sha256Fingerprint: .init(
        certificate: "5e f2 f2 14 26 0a b8 f5 8e 55 ee a4 2e 4a c0 4b 0f 17 18 07 d8 d1 18 5f dd d6 74 70 e9 ab 60 96",
        publicKey: "5e cf a9 8d 1a 76 dd 09 26 5d e1 f7 d4 a1 00 8c cd 5a 5a fc 69 1d 3e af 63 2f aa da 5b 6a b5 a3"
      )
    )
  }
}
#endif
