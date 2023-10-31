//
//  TestX509Parser.swift
//  
//
//  Created by Yuya Oka on 2023/10/27.
//

@testable import X509Parser
import XCTest

final class TestX509Parser: XCTestCase {
    func testParse() throws {
        let derURL = Bundle.module.url(forResource: "example-com", withExtension: "der")!
        let derData = try Data(contentsOf: derURL)
        let x509 = try X509Parser.parse(from: derData)

        XCTAssertEqual(x509.version, "3")
        XCTAssertEqual(x509.serialNumber, "0c:1f:cb:18:45:18:c7:e3:86:67:41:23:6d:6b:73:f1")
        XCTAssertEqual(x509.notValidBefore, .init(timeIntervalSinceReferenceDate: 695260800))
        XCTAssertEqual(x509.notValidAfter, .init(timeIntervalSinceReferenceDate: 729561599))
        XCTAssertEqual(x509.issuer.commonName, "DigiCert TLS RSA SHA256 2020 CA1")
        XCTAssertEqual(x509.issuer.organization, "DigiCert Inc")
        XCTAssertNil(x509.issuer.organizationalUnit)
        XCTAssertEqual(x509.issuer.country, "US")
        XCTAssertNil(x509.issuer.stateOrProvinceName)
        XCTAssertNil(x509.issuer.locality)
        XCTAssertEqual(x509.issuer.all, "CN=DigiCert TLS RSA SHA256 2020 CA1\nO=DigiCert Inc\nC=US")
        XCTAssertEqual(x509.subject.commonName, "www.example.org")
        XCTAssertEqual(x509.subject.organization, "Internet Corporation for Assigned Names and Numbers")
        XCTAssertNil(x509.subject.organizationalUnit)
        XCTAssertEqual(x509.subject.country, "US")
        XCTAssertEqual(x509.subject.stateOrProvinceName, "California")
        XCTAssertEqual(x509.subject.locality, "Los Angeles")
        XCTAssertEqual(
            x509.subject.all,
            "CN=www.example.org\nO=Internet Corporation for Assigned Names and Numbers\nL=Los Angeles\nST=California\nC=US"
        )
        XCTAssertEqual(
            x509.sha256Fingerprint,
            .init(
                certificate: "5e f2 f2 14 26 0a b8 f5 8e 55 ee a4 2e 4a c0 4b 0f 17 18 07 d8 d1 18 5f dd d6 74 70 e9 ab 60 96",
                publicKey: "5e cf a9 8d 1a 76 dd 09 26 5d e1 f7 d4 a1 00 8c cd 5a 5a fc 69 1d 3e af 63 2f aa da 5b 6a b5 a3"
            )
        )
    }
}
