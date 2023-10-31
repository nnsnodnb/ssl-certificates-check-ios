//
//  SearchResultPage.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import ComposableArchitecture
import SwiftUI
import UIComponents
import X509Parser

@MainActor
package struct SearchResultPage: View {
    // MARK: - Properties
    package let store: StoreOf<SearchResultReducer>

    // MARK: - Body
    package var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            list(viewStore)
        })
    }
}

// MARK: - Private method
private extension SearchResultPage {
    func list(_ viewStore: ViewStoreOf<SearchResultReducer>) -> some View {
        List {
            ForEach(viewStore.certificates) { certificate in
                row(viewStore, for: certificate)
            }
        }
    }

    @ViewBuilder
    func row(_ viewStore: ViewStoreOf<SearchResultReducer>, for x509: X509) -> some View {
        if let commonName = x509.subject.commonName {
            HStack(alignment: .center, spacing: 0) {
                Button(
                    action: {
                        viewStore.send(.selectCertificate(x509), animation: .default)
                    },
                    label: {
                        HStack(alignment: .center, spacing: 0) {
                            Text(commonName)
                            Spacer()
                            ListRowChevronRight()
                        }
                    }
                )
                .tint(.primary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#if DEBUG
// swiftlint:disable force_try
// swiftlint:disable line_length
#Preview {
    SearchResultPage(
        store: .init(
            initialState: SearchResultReducer.State(
                certificates: .init(
                    uniqueElements: [
                        X509(
                            version: "3",
                            serialNumber: "16115816404043435608139631424403370993",
                            notValidBefore: .init(),
                            notValidAfter: .init(),
                            issuer: try! .init(value: "C=US,O=DigiCert Inc,CN=DigiCert TLS RSA SHA256 2020 CA1"),
                            subject: try! .init(value: "C=US,ST=California,L=Los Angeles,O=Internet C2 Corporation for Assigned Names and Numbers,CN=www.example.org"),
                            sha256Fingerprint: "5e f2 f2 14 26 0a b8 f5 8e 55 ee a4 2e 4a c0 4b 0f 17 18 07 d8 d1 18 5f dd d6 74 70 e9 ab 60 96"
                        )
                    ]
                )
            )
        ) {
            SearchResultReducer()
        }
    )
}
// swiftlint:enable force_try
// swiftlint:enable line_length
#endif
