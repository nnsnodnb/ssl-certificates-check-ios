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
            otherSection(viewStore)
            contentSection(title: "Issued to", distinguishedNames: viewStore.x509.subject)
            contentSection(title: "Issued by", distinguishedNames: viewStore.x509.issuer)
            validityPeriodSection(viewStore)
            sha256FingerprintSection(viewStore)
        }
        .formStyle(.grouped)
    }

    func otherSection(_ viewStore: ViewStoreOf<SearchResultDetailReducer>) -> some View {
        Section {
            item(title: "Version", content: "Version \(viewStore.x509.version)")
            item(title: "Serial Number", content: viewStore.x509.serialNumber)
        }
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

    func sha256FingerprintSection(_ viewStore: ViewStoreOf<SearchResultDetailReducer>) -> some View {
        Section(
            content: {
                item(title: "Certificate", content: viewStore.x509.sha256Fingerprint.certificate)
                item(title: "Public key", content: viewStore.x509.sha256Fingerprint.publicKey)
            },
            header: {
                Text("SHA256 Fingerprints")
                    .font(.system(size: 14))
            }
        )
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

#if DEBUG
#Preview {
    SearchResultDetailPage(
        store: .init(
            initialState: SearchResultDetailReducer.State(x509: .stub)
        ) {
            SearchResultDetailReducer()
        }
    )
}
#endif
