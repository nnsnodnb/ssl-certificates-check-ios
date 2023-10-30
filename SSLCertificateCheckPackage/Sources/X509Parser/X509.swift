//
//  X509.swift
//
//
//  Created by Yuya Oka on 2023/10/27.
//

import Foundation

package struct X509: Hashable, Sendable {
    // MARK: - Properties
    package let version: String
    package let serialNumber: String
    package let notValidBefore: Date
    package let notValidAfter: Date
    package let issuer: DistinguishedNames
    package let subject: DistinguishedNames
    package let sha256Fingerprint: String
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
        package init(
            commonName: String?,
            organization: String?,
            organizationalUnit: String?,
            country: String?,
            stateOrProvinceName: String?,
            locality: String?,
            all: String
        ) {
            self.commonName = commonName
            self.organization = organization
            self.organizationalUnit = organizationalUnit
            self.country = country
            self.stateOrProvinceName = stateOrProvinceName
            self.locality = locality
            self.all = all
        }

        package init(value: String) throws {
            let attributes = value.split(separator: ",")
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
