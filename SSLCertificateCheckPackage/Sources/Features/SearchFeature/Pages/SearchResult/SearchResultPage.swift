//
//  SearchResultPage.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import SwiftUI

@MainActor
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
    SearchResultPage(x509: .stub)
}
#endif
