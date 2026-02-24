//
//  X509Parser.swift
//
//
//  Created by Yuya Oka on 2023/10/27.
//

import _CryptoExtras
import CryptoKit
import Foundation
import X509

package struct X509Parser {
  // MARK: - Error
  package enum Error: Swift.Error {
    case notExistsCertificates
    case unknown
  }

  package static func parse(serverTrust: SecTrust) throws -> [X509] {
    var error: CFError?
    guard SecTrustEvaluateWithError(serverTrust, &error) else {
      throw error ?? Error.unknown
    }
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

  package static func parse(from derData: Data) throws -> X509 {
    let count = derData.count
    let derEncoded = derData.withUnsafeBytes {
      let address = $0.bindMemory(to: UInt8.self).baseAddress
      return [UInt8](UnsafeBufferPointer(start: address, count: count))
    }
    let certificate = try Certificate(derEncoded: derEncoded)
    // TODO: extensions, signature, signatureAlgorithm
    let version = certificate.version.description.replacingOccurrences(of: "X509v", with: "")
    let serialNumber = Data(certificate.serialNumber.bytes).hexadecimalString(separator: ":")
    let issuer = try X509.DistinguishedNames(attributes: certificate.issuer.reversed().map { String(describing: $0) })
    let subject = try X509.DistinguishedNames(attributes: certificate.subject.reversed().map { String(describing: $0) })
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
}
