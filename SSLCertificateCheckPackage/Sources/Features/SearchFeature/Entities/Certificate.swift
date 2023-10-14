//
//  X509.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import Foundation
import OpenSSL

package struct X509: Sendable, Hashable {
    // MARK: - Properties
    package let certificates: [Certificate]

    // MARK: - Error
    package enum Error: Swift.Error {
        case notExistsCertificates
        case unknown
    }

    // MARK: - Initialize
    init(serverTrust: SecTrust) throws {
        var error: CFError?
        guard SecTrustEvaluateWithError(serverTrust, &error) else {
            throw error as? Error ?? Error.unknown
        }
        guard let serverCertificates = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate] else {
            throw Error.notExistsCertificates
        }
        self.certificates = try serverCertificates
            .enumerated()
            .map { number, certificate in
                let data = SecCertificateCopyData(certificate) as Data
                let x509 = try OpenSSL.X509(der: data)

                let subject = try Content(x509.subjectOneLine())
                let issuer = try Content(x509.issuerOneLine())
                let serialNumber = try x509.serialNumber()
                let issuedAt = try x509.notBefore()
                let expiredAt = try x509.notAfter()
                let sha256Fingerprint = try x509.sha256Fingerprint()
                    .map { String(format: "%.2hhx", $0) }
                    .joined(separator: " ")
                return Certificate(
                    id: number,
                    subject: subject,
                    issuer: issuer,
                    serialNumber: serialNumber,
                    issuedAt: issuedAt,
                    expiredAt: expiredAt,
                    sha256Fingerprint: sha256Fingerprint
                )
            }
    }

    #if DEBUG
    init(certificates: [Certificate]) {
        self.certificates = certificates
    }
    #endif
}

// MARK: - Certificate
package extension X509 {
    struct Certificate: Sendable, Identifiable, Hashable {
        // MARK: - Properties
        package let id: Int
        package let subject: Content
        package let issuer: Content
        package let serialNumber: String
        package let issuedAt: Date
        package let expiredAt: Date
        package let sha256Fingerprint: String
    }
}

// MARK: - Subject
package extension X509 {
    struct Content: Sendable, Hashable {
        // MARK: - Properties
        package let commonName: String
        package let organization: String?
        package let organizationUnit: String?
        package let country: String?
        package let all: String

        // MARK: - Initialize
        package init(_ text: String) {
            let elements = text.split(separator: "/")
            // CN
            if let element = elements.lazy.first(where: { $0.starts(with: "CN=") }) {
                self.commonName = element
                    .replacingOccurrences(of: "CN=", with: "")
                    .replacingOccurrences(of: "\\xC2\\xA0", with: " ")
            } else {
                self.commonName = "Unknown"
            }
            // O
            if let element = elements.lazy.first(where: { $0.starts(with: "O=") }) {
                self.organization = element
                    .replacingOccurrences(of: "O=", with: "")
                    .replacingOccurrences(of: "\\xC2\\xA0", with: " ")
            } else {
                self.organization = nil
            }
            // OU
            if let element = elements.lazy.first(where: { $0.starts(with: "OU=") }) {
                self.organizationUnit = element
                    .replacingOccurrences(of: "OU=", with: "")
                    .replacingOccurrences(of: "\\xC2\\xA0", with: " ")
            } else {
                self.organizationUnit = nil
            }
            // C
            if let element = elements.lazy.first(where: { $0.starts(with: "C=") }) {
                self.country = element
                    .replacingOccurrences(of: "C=", with: "")
                    .replacingOccurrences(of: "\\xC2\\xA0", with: " ")
            } else {
                self.country = nil
            }

            self.all = elements.joined(separator: "\n").replacingOccurrences(of: "\\xC2\\xA0", with: " ")
        }
    }
}
