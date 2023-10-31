//
//  SearchResultDetailPage.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import ComposableArchitecture
import SwiftUI
import X509Parser

@MainActor
package struct SearchResultDetailPage: View {
    // MARK: - Properties
    package let store: StoreOf<SearchResultDetailReducer>

    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .full
        return dateFormatter
    }()

    // MARK: - Body
    package var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            form(viewStore)
                .navigationTitle(viewStore.x509.subject.commonName ?? "")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    viewStore.send(.appear)
                }
        })
    }
}

// MARK: - Private method
@MainActor
private extension SearchResultDetailPage {
    func form(_ viewStore: ViewStoreOf<SearchResultDetailReducer>) -> some View {
        Form {
            contentSection(title: "Issued to", distinguishedNames: viewStore.x509.subject)
            contentSection(title: "Issued by", distinguishedNames: viewStore.x509.issuer)
            validityPeriodSection(viewStore)
            otherSection(viewStore)
        }
        .formStyle(.grouped)
    }

    func contentSection(title: String, distinguishedNames: X509.DistinguishedNames) -> some View {
        Section(
            content: {
                if let commonName = distinguishedNames.commonName {
                    item(title: "Common name", content: commonName)
                }
                if let organization = distinguishedNames.organization {
                    item(title: "Organization", content: organization)
                }
                if let organizationalUnit = distinguishedNames.organizationalUnit {
                    item(title: "Organizational unit", content: organizationalUnit)
                }
                if let country = distinguishedNames.country {
                    item(title: "Country", content: country)
                }
                if let stateOrProvinceName = distinguishedNames.stateOrProvinceName {
                    item(title: "State or Province name", content: stateOrProvinceName)
                }
                if let locality = distinguishedNames.locality {
                    item(title: "Locality", content: locality)
                }
                item(title: nil, content: distinguishedNames.all)
            },
            header: {
                Text(title)
                    .font(.system(size: 14))
            }
        )
    }

    func validityPeriodSection(_ viewStore: ViewStoreOf<SearchResultDetailReducer>) -> some View {
        Section(
            content: {
                item(title: "Issued", content: dateFormatter.string(from: viewStore.x509.notValidBefore))
                item(title: "Expired", content: dateFormatter.string(from: viewStore.x509.notValidAfter))
            },
            header: {
                Text("Validity Period")
                    .font(.system(size: 14))
            }
        )
    }

    func otherSection(_ viewStore: ViewStoreOf<SearchResultDetailReducer>) -> some View {
        Section {
            item(title: "Serial Number", content: viewStore.x509.serialNumber)
            item(title: "SHA-256 Fingerprint", content: viewStore.x509.sha256Fingerprint)
        }
    }

    func item(title: String?, content: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if let title {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            Text(content)
                .textSelection(.enabled)
        }
    }
}

// swiftlint:disable force_try
// swiftlint:disable line_length
#Preview {
    SearchResultDetailPage(
        store: .init(
            initialState: SearchResultDetailReducer.State(
                x509: X509(
                    version: "3",
                    serialNumber: "16115816404043435608139631424403370993",
                    notValidBefore: .init(),
                    notValidAfter: .init(),
                    issuer: try! .init(value: "C=US,O=DigiCert Inc,CN=DigiCert TLS RSA SHA256 2020 CA1"),
                    subject: try! .init(value: "C=US,ST=California,L=Los Angeles,O=Internet C2 Corporation for Assigned Names and Numbers,CN=www.example.org"),
                    sha256Fingerprint: "5e f2 f2 14 26 0a b8 f5 8e 55 ee a4 2e 4a c0 4b 0f 17 18 07 d8 d1 18 5f dd d6 74 70 e9 ab 60 96"
                )
            )
        ) {
            SearchResultDetailReducer()
        }
    )
}
// swiftlint:enable force_try
// swiftlint:enable line_length
