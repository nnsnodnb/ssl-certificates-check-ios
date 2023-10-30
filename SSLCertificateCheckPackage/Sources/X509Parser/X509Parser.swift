//
//  X509Parser.swift
//
//
//  Created by Yuya Oka on 2023/10/27.
//

import CryptoKit
import Foundation
import X509

package struct X509Parser {
    package static func parse(from derData: Data) throws -> X509 {
        let count = derData.count
        let derEncoded = derData.withUnsafeBytes {
            let address = $0.bindMemory(to: UInt8.self).baseAddress
            return [UInt8](UnsafeBufferPointer(start: address, count: count))
        }
        let certificate = try Certificate(derEncoded: derEncoded)
        // TODO: extensions, signature, signatureAlgorithm
        let version = certificate.version.description.replacingOccurrences(of: "X509v", with: "")
        let serialNumber = certificate.serialNumber.bytes.map { String(format: "%0.2x", $0) }.joined(separator: ":")
        let issuer = try X509.DistinguishedNames(value: certificate.issuer.description)
        let subject = try X509.DistinguishedNames(value: certificate.subject.description)
        let sha256Fingerprint = SHA256.hash(data: derData).map { String(format: "%0.2x", $0) }.joined(separator: " ")

        let x509 = X509(
            version: version,
            serialNumber: serialNumber,
            notValidBefore: certificate.notValidBefore,
            notValidAfter: certificate.notValidAfter,
            issuer: issuer,
            subject: subject,
            sha256Fingerprint: sha256Fingerprint
        )
        return x509
    }
}
