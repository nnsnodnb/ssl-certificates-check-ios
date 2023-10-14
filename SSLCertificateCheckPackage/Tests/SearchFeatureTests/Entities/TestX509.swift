//
//  TestX509.swift
//  
//
//  Created by Yuya Oka on 2023/10/15.
//

@testable import SearchFeature
import XCTest

final class TestX509: XCTestCase {
    // swiftlint:disable:next function_body_length
    func testInitSecTrust() throws {
        guard let exampleComDerURL = Bundle.module.url(forResource: "example-com", withExtension: "der") else {
            throw "Not found example-com.der file."
        }
        guard let ca1DerURL = Bundle.module.url(forResource: "DigiCert TLS RSA SHA256 2020 CA1", withExtension: "der") else {
            throw "Not found DigiCert TLS RSA SHA256 2020 CA1.der file."
        }
        guard let rootDerURL = Bundle.module.url(forResource: "DigiCert Global Root CA", withExtension: "der") else {
            throw "Not found DigiCert Global Root CA.der file."
        }
        let exampleComCertificate = SecCertificateCreateWithData(
            kCFAllocatorDefault,
            try Data(contentsOf: exampleComDerURL) as CFData
        )
        let ca1Certificate = SecCertificateCreateWithData(kCFAllocatorDefault, try Data(contentsOf: ca1DerURL) as CFData)
        let rootCertificate = SecCertificateCreateWithData(kCFAllocatorDefault, try Data(contentsOf: rootDerURL) as CFData)
        let certificates = [
            exampleComCertificate,
            ca1Certificate,
            rootCertificate
        ]
        var serverTrust: SecTrust?
        let status = SecTrustCreateWithCertificates(certificates as AnyObject, SecPolicyCreateBasicX509(), &serverTrust)
        guard status == errSecSuccess else {
            throw "Failure SecTrustCreateWithCertificates"
        }
        let x509 = try X509(serverTrust: serverTrust!)

        // swiftlint:disable line_length
        XCTAssertEqual(
            x509.certificates,
            [
                .init(
                    id: 0,
                    subject: .init(
                        "/C=US/ST=California/L=Los Angeles/O=Internet\\xC2\\xA0Corporation\\xC2\\xA0for\\xC2\\xA0Assigned\\xC2\\xA0Names\\xC2\\xA0and\\xC2\\xA0Numbers/CN=www.example.org"
                    ),
                    issuer: .init(
                        "/C=US/O=DigiCert Inc/CN=DigiCert TLS RSA SHA256 2020 CA1"
                    ),
                    serialNumber: "16115816404043435608139631424403370993",
                    issuedAt: .init(timeIntervalSinceReferenceDate: 695260800),
                    expiredAt: .init(timeIntervalSinceReferenceDate: 729561599),
                    sha256Fingerprint: "5e f2 f2 14 26 0a b8 f5 8e 55 ee a4 2e 4a c0 4b 0f 17 18 07 d8 d1 18 5f dd d6 74 70 e9 ab 60 96"
                ),
                .init(
                    id: 1,
                    subject: .init(
                        "/C=US/O=DigiCert Inc/CN=DigiCert TLS RSA SHA256 2020 CA1"
                    ),
                    issuer: .init(
                        "/C=US/O=DigiCert Inc/OU=www.digicert.com/CN=DigiCert Global Root CA"
                    ),
                    serialNumber: "9101305761976670746388865003982847684",
                    issuedAt: .init(timeIntervalSinceReferenceDate: 640051200),
                    expiredAt: .init(timeIntervalSinceReferenceDate: 955583999),
                    sha256Fingerprint: "52 27 4c 57 ce 4d ee 3b 49 db 7a 7f f7 08 c0 40 f7 71 89 8b 3b e8 87 25 a8 6f b4 43 01 82 fe 14"
                ),
                .init(
                    id: 2,
                    subject: .init(
                        "/C=US/O=DigiCert Inc/OU=www.digicert.com/CN=DigiCert Global Root CA"
                    ),
                    issuer: .init(
                        "/C=US/O=DigiCert Inc/OU=www.digicert.com/CN=DigiCert Global Root CA"
                    ),
                    serialNumber: "10944719598952040374951832963794454346",
                    issuedAt: .init(timeIntervalSinceReferenceDate: 184809600),
                    expiredAt: .init(timeIntervalSinceReferenceDate: 973728000),
                    sha256Fingerprint: "43 48 a0 e9 44 4c 78 cb 26 5e 05 8d 5e 89 44 b4 d8 4f 96 62 bd 26 db 25 7f 89 34 a4 43 c7 01 61"
                )
            ]
        )
        // swiftlint:enable line_length
    }
}
