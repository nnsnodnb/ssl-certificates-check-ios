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
            throw error ?? Error.unknown
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
        package let stateOrProvinceName: String?
        package let locality: String?
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
            // ST/S
            if let element = elements.lazy.first(where: { $0.starts(with: "ST=") || $0.starts(with: "S=") }) {
                self.stateOrProvinceName = element
                    .replacingOccurrences(of: "ST=", with: "")
                    .replacingOccurrences(of: "S=", with: "")
                    .replacingOccurrences(of: "\\xC2\\xA0", with: " ")
            } else {
                self.stateOrProvinceName = nil
            }
            // L
            if let element = elements.lazy.first(where: { $0.starts(with: "L=") }) {
                self.locality = element
                    .replacingOccurrences(of: "L=", with: "")
                    .replacingOccurrences(of: "\\xC2\\xA0", with: " ")
            } else {
                self.locality = nil
            }

            self.all = elements.joined(separator: "\n").replacingOccurrences(of: "\\xC2\\xA0", with: " ")
        }
    }
}

#if DEBUG
package extension X509 {
    static let stub: Self = .init(
        certificates: [
            .init(
                id: 1,
                subject: .init("/C=US/ST=California/L=Los Angeles/O=Internet\\xC2\\xA0Corporation\\xC2\\xA0for\\xC2\\xA0Assigned\\xC2\\xA0Names\\xC2\\xA0and\\xC2\\xA0Numbers/CN=www.example.org"), // swiftlint:disable:this line_length
                issuer: .init("/C=US/O=DigiCert Inc/CN=DigiCert TLS RSA SHA256 2020 CA1"),
                serialNumber: "16115816404043435608139631424403370993",
                issuedAt: .init(),
                expiredAt: .init(),
                sha256Fingerprint: "5e f2 f2 14 26 0a b8 f5 8e 55 ee a4 2e 4a c0 4b 0f 17 18 07 d8 d1 18 5f dd d6 74 70 e9 ab 60 96" // swiftlint:disable:this line_length
            )
        ]
    )
}
#endif
