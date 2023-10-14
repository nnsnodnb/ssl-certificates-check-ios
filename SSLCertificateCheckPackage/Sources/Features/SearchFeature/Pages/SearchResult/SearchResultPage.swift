//
//  SearchResultPage.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import SwiftUI

package struct SearchResultPage: View {
    // MARK: - Properties
    package let x509: X509

    // MARK: - Body
    package var body: some View {
        List {
            ForEach(x509.certificates) { certificate in
                NavigationLink(
                    destination: {
                        SearchResultDetailPage(certificate: certificate)
                    },
                    label: {
                        Text(certificate.subject.commonName)
                    }
                )
            }
        }
    }
}

#if DEBUG
#Preview {
    SearchResultPage(
        x509: .init(
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
    )
}
#endif
