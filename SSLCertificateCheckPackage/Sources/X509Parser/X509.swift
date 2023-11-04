//
//  X509.swift
//
//
//  Created by Yuya Oka on 2023/10/27.
//

import Foundation

package struct X509: Hashable, Sendable, Identifiable {
    // MARK: - Properties
    package var id: String { serialNumber }

    package let version: String
    package let serialNumber: String
    package let notValidBefore: Date
    package let notValidAfter: Date
    package let issuer: DistinguishedNames
    package let subject: DistinguishedNames
    package let sha256Fingerprint: SHA256Fingerprint

    // MARK: - Initialize
    package init(
        version: String,
        serialNumber: String,
        notValidBefore: Date,
        notValidAfter: Date,
        issuer: DistinguishedNames,
        subject: DistinguishedNames,
        sha256Fingerprint: SHA256Fingerprint
    ) {
        self.version = version
        self.serialNumber = serialNumber
        self.notValidBefore = notValidBefore
        self.notValidAfter = notValidAfter
        self.issuer = issuer
        self.subject = subject
        self.sha256Fingerprint = sha256Fingerprint
    }
}

// MARK: - DistinguishedNames
package extension X509 {
    struct DistinguishedNames: Hashable, Sendable {
        // MARK: - Properties
        package let commonName: String?
        package let organization: String?
        package let organizationalUnit: String?
        package let country: String?
        package let stateOrProvinceName: String?
        package let locality: String?
        package let all: String

        // MARK: - Error
        package enum Error: Swift.Error {
            case invalidFormat
        }

        // MARK: - Initialize
        package init(attributes: [String]) throws {
            let attributes = attributes.map { $0.replacingOccurrences(of: "\\", with: "") }
            // CN
            if let element = attributes.lazy.first(where: { $0.starts(with: "CN=") }) {
                self.commonName = element.replacingOccurrences(of: "CN=", with: "")
            } else {
                self.commonName = nil
            }
            // O
            if let element = attributes.lazy.first(where: { $0.starts(with: "O=") }) {
                self.organization = element.replacingOccurrences(of: "O=", with: "")
            } else {
                self.organization = nil
            }
            // OU
            if let element = attributes.lazy.first(where: { $0.starts(with: "OU=") }) {
                self.organizationalUnit = element.replacingOccurrences(of: "OU=", with: "")
            } else {
                self.organizationalUnit = nil
            }
            // C
            if let element = attributes.lazy.first(where: { $0.starts(with: "C=") }) {
                self.country = element.replacingOccurrences(of: "C=", with: "")
            } else {
                self.country = nil
            }
            // ST or S
            if let element = attributes.lazy.first(where: { $0.starts(with: #/S(T)?=/#) }) {
                self.stateOrProvinceName = element
                    .replacingOccurrences(of: "ST=", with: "")
                    .replacingOccurrences(of: "S=", with: "")
            } else {
                self.stateOrProvinceName = nil
            }
            // L
            if let element = attributes.lazy.first(where: { $0.starts(with: "L=") }) {
                self.locality = element.replacingOccurrences(of: "L=", with: "")
            } else {
                self.locality = nil
            }

            self.all = attributes.joined(separator: "\n")
        }
    }
}

// MARK: - SHA256Fingerprint
package extension X509 {
    struct SHA256Fingerprint: Hashable, Sendable {
        // MARK: - Properties
        package let certificate: String
        package let publicKey: String

        // MARK: - Initialize
        package init(certificate: String, publicKey: String) {
            self.certificate = certificate
            self.publicKey = publicKey
        }
    }
}

#if DEBUG
// swiftlint:disable force_try
// swiftlint:disable line_length
package extension X509 {
    static var stub: Self {
        .init(
            version: "3",
            serialNumber: "16115816404043435608139631424403370993",
            notValidBefore: .init(),
            notValidAfter: .init(),
            issuer: try! .init(attributes: ["C=US", "O=DigiCert Inc", "CN=DigiCert TLS RSA SHA256 2020 CA1"]),
            subject: try! .init(
                attributes: [
                    "C=US",
                    "ST=California",
                    "L=Los Angeles",
                    "O=Internet C2 Corporation for Assigned Names and Numbers",
                    "CN=www.example.org"
                ]
            ),
            sha256Fingerprint: .init(
                certificate: "5e f2 f2 14 26 0a b8 f5 8e 55 ee a4 2e 4a c0 4b 0f 17 18 07 d8 d1 18 5f dd d6 74 70 e9 ab 60 96",
                publicKey: "5e cf a9 8d 1a 76 dd 09 26 5d e1 f7 d4 a1 00 8c cd 5a 5a fc 69 1d 3e af 63 2f aa da 5b 6a b5 a3"
            )
        )
    }
}
// swiftlint:enable force_try
// swiftlint:enable line_length
#endif
