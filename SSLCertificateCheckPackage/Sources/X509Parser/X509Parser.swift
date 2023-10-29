//
//  X509Parser.swift
//
//
//  Created by Yuya Oka on 2023/10/27.
//

import Foundation
import X509

package struct X509Parser {
    // MARK: - Properties
    private let x509: Certificate

    package static func parse(from derData: Data) throws -> X509 {
        let count = derData.count
        let derEncoded = derData.withUnsafeBytes {
            let address = $0.bindMemory(to: UInt8.self).baseAddress
            return [UInt8](UnsafeBufferPointer(start: address, count: count))
        }
        let certificate = try Certificate(derEncoded: derEncoded)
        _ = certificate.version.description.replacingOccurrences(of: "X509", with: "")
        _ = certificate.serialNumber.bytes.map { String(format: "%0.2x", $0) }.joined(separator: ":")
        _ = certificate.publicKey.description.replacingOccurrences(of: ".PublicKey", with: "")
        _ = certificate.notValidBefore
        _ = certificate.notValidAfter
        _ = certificate.issuer.map { $0.description }
        certificate.subject.map { $0.description }
        certificate.extensions
        certificate.signature
        certificate.signatureAlgorithm
        let x509 = X509()
        return x509
    }
}
