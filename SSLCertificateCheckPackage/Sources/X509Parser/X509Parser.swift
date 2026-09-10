//
//  X509Parser.swift
//
//
//  Created by Yuya Oka on 2023/10/27.
//

import _CryptoExtras
import CryptoKit
import Foundation
import SwiftASN1
import X509

public struct X509Parser {
  // MARK: - Error
  public enum Error: Swift.Error {
    case notExistsCertificates
    case unknown
    case unsupportedEncoding
  }

  public static func parse(serverTrust: SecTrust) throws -> [X509] {
    guard let serverCertificates = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate] else {
      throw Error.notExistsCertificates
    }
    let x509Certificates = try serverCertificates.map { certificate in
      let data = SecCertificateCopyData(certificate) as Data
      let x509 = try Self.parse(from: data)
      return x509
    }
    return x509Certificates
  }

  public static func parse(from derData: Data) throws -> X509 {
    let certificate = try Certificate(derEncoded: [UInt8](derData))
    // TODO: extensions, signature, signatureAlgorithm
    let version = certificate.version.description.replacingOccurrences(of: "X509v", with: "")
    let serialNumber = Data(certificate.serialNumber.bytes).hexadecimalString(separator: ":")
    let issuer = try Self.parseDistinguishedNames(certificate.issuer, certificate: certificate)
    let subject = try Self.parseDistinguishedNames(certificate.subject, certificate: certificate)
    let certificateSHA256Fingerprint = SHA256.hash(data: derData).hexadecimalString(separator: " ")
    let publicKeySHA256Fingerprint = SHA256.hash(data: {
      if let p256 = P256.Signing.PublicKey(certificate.publicKey) {
        return p256.derRepresentation
      } else if let p384 = P384.Signing.PublicKey(certificate.publicKey) {
        return p384.derRepresentation
      } else if let p521 = P521.Signing.PublicKey(certificate.publicKey) {
        return p521.derRepresentation
      } else if let rsa = _RSA.Signing.PublicKey(certificate.publicKey) {
        return rsa.derRepresentation
      } else {
        return Data()
      }
    }()).hexadecimalString(separator: " ")

    let x509 = X509(
      version: version,
      serialNumber: serialNumber,
      notValidBefore: certificate.notValidBefore,
      notValidAfter: certificate.notValidAfter,
      issuer: issuer,
      subject: subject,
      sha256Fingerprint: .init(
        certificate: certificateSHA256Fingerprint,
        publicKey: publicKeySHA256Fingerprint
      )
    )
    return x509
  }

  // swiftlint:disable cyclomatic_complexity
  // swiftlint:disable:next function_body_length
  private static func parseDistinguishedNames(
    _ distinguishedNames: DistinguishedName,
    certificate: Certificate,
  ) throws -> X509.DistinguishedNames {
    var serializer = DER.Serializer()
    try distinguishedNames.serialize(into: &serializer)
    let node = try DER.parse(serializer.serializedBytes)
    guard case let .constructed(rdnNodes) = node.content else {
      throw Error.unknown
    }

    var commonName: String?
    var organization: String?
    var organizationalUnit: String?
    var country: String?
    var stateOrProvinceName: String?
    var locality: String?
    var streetAddress: String?
    var domainComponent: String?
    var emailAddress: String?

    for rdn in rdnNodes {
      guard case let .constructed(attributeNodes) = rdn.content else {
        continue
      }
      for attributeNode in attributeNodes {
        guard case let .constructed(fields) = attributeNode.content else {
          continue
        }
        let fieldNodes = Array(fields)
        guard fieldNodes.count == 2 else { continue }
        let oid = try ASN1ObjectIdentifier(derEncoded: fieldNodes[0])
        switch oid {
        case .RDNAttributeType.commonName:
          commonName = try Self.decodedString(from: fieldNodes[1])
        case .RDNAttributeType.organizationName:
          organization = try Self.decodedString(from: fieldNodes[1])
        case .RDNAttributeType.organizationalUnitName:
          organizationalUnit = try Self.decodedString(from: fieldNodes[1])
        case .RDNAttributeType.countryName:
          country = try Self.decodedString(from: fieldNodes[1])
        case .RDNAttributeType.stateOrProvinceName:
          stateOrProvinceName = try Self.decodedString(from: fieldNodes[1])
        case .RDNAttributeType.localityName:
          locality = try Self.decodedString(from: fieldNodes[1])
        case .RDNAttributeType.streetAddress:
          streetAddress = try Self.decodedString(from: fieldNodes[1])
        case .RDNAttributeType.domainComponent:
          domainComponent = try Self.decodedString(from: fieldNodes[1])
        case .RDNAttributeType.emailAddress:
          emailAddress = try Self.decodedString(from: fieldNodes[1])
        default:
          continue
        }
      }
    }

    return X509.DistinguishedNames(
      commonName: commonName,
      organization: organization,
      organizationalUnit: organizationalUnit,
      country: country,
      stateOrProvinceName: stateOrProvinceName,
      locality: locality,
      streetAddress: streetAddress,
      domainComponent: domainComponent,
      emailAddress: emailAddress,
    )
  }
  // swiftlint:enable cyclomatic_complexity

  private static func decodedString(from node: ASN1Node) throws -> String {
    if let value = try? ASN1UTF8String(derEncoded: node) {
      return String(value)
    }
    if let value = try? ASN1PrintableString(derEncoded: node) {
      return String(value)
    }
    if let value = try? ASN1IA5String(derEncoded: node) {
      return String(value)
    }
    if let value = try? ASN1TeletexString(derEncoded: node) {
      return String(bytes: value.bytes, encoding: .utf8) ?? "Unknown"
    }
    if case let .primitive(bytes) = node.content {
      return String(bytes: bytes, encoding: .utf8) ?? "Unknown"
    }
    throw Error.unsupportedEncoding
  }
}

#if DEBUG
import Playgrounds

#Playground {
  guard let url = Bundle.module.url(forResource: "expired-badssl-com", withExtension: "der") else { return }
  let derData = try Data(contentsOf: url)
  let certificate = try Certificate(derEncoded: [UInt8](derData))
  _ = certificate
}
#endif
