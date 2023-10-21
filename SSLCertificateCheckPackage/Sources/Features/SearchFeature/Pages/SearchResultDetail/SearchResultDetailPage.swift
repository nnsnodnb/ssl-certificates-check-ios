//
//  SearchResultDetailPage.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import ComposableArchitecture
import SwiftUI

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
                .navigationTitle(viewStore.certificate.subject.commonName)
                .navigationBarTitleDisplayMode(.inline)
        })
    }
}

// MARK: - Private method
@MainActor
private extension SearchResultDetailPage {
    func form(_ viewStore: ViewStoreOf<SearchResultDetailReducer>) -> some View {
        Form {
            contentSection(title: "Issued to", content: viewStore.certificate.subject)
            contentSection(title: "Issued by", content: viewStore.certificate.issuer)
            validityPeriodSection(viewStore)
            otherSection(viewStore)
        }
        .formStyle(.grouped)
    }

    func contentSection(title: String, content: X509.Content) -> some View {
        Section(
            content: {
                item(title: "Common name", content: content.commonName)
                if let organization = content.organization {
                    item(title: "Organization", content: organization)
                }
                if let organizationUnit = content.organizationUnit {
                    item(title: "Organization unit", content: organizationUnit)
                }
                if let country = content.country {
                    item(title: "Country", content: country)
                }
                item(title: nil, content: content.all)
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
                item(title: "Issued", content: dateFormatter.string(from: viewStore.certificate.issuedAt))
                item(title: "Expired", content: dateFormatter.string(from: viewStore.certificate.expiredAt))
            },
            header: {
                Text("Validity Period")
                    .font(.system(size: 14))
            }
        )
    }

    func otherSection(_ viewStore: ViewStoreOf<SearchResultDetailReducer>) -> some View {
        Section {
            item(title: "Serial Number", content: viewStore.certificate.serialNumber)
            item(title: "SHA-256 Fingerprint", content: viewStore.certificate.sha256Fingerprint)
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

#Preview {
    SearchResultDetailPage(
        store: .init(
            initialState: SearchResultDetailReducer.State(
                certificate: .init(
                    id: 1,
                    subject: .init("/C=US/ST=California/L=Los Angeles/O=Internet\\xC2\\xA0Corporation\\xC2\\xA0for\\xC2\\xA0Assigned\\xC2\\xA0Names\\xC2\\xA0and\\xC2\\xA0Numbers/CN=www.example.org"), // swiftlint:disable:this line_length
                    issuer: .init("/C=US/O=DigiCert Inc/CN=DigiCert TLS RSA SHA256 2020 CA1"),
                    serialNumber: "16115816404043435608139631424403370993",
                    issuedAt: .init(),
                    expiredAt: .init(),
                    sha256Fingerprint: "5e f2 f2 14 26 0a b8 f5 8e 55 ee a4 2e 4a c0 4b 0f 17 18 07 d8 d1 18 5f dd d6 74 70 e9 ab 60 96" // swiftlint:disable:this line_length
                )
            )
        ) {
            SearchResultDetailReducer()
        }
    )
}
