//
//  SearchResultPage.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import ComposableArchitecture
import SwiftUI
import UIComponents

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

    func row(_ viewStore: ViewStoreOf<SearchResultReducer>, for certificate: X509.Certificate) -> some View {
        HStack(alignment: .center, spacing: 0) {
            Button(
                action: {
                    viewStore.send(.selectCertificate(certificate), animation: .default)
                },
                label: {
                    HStack(alignment: .center, spacing: 0) {
                        Text(certificate.subject.commonName)
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

#if DEBUG
#Preview {
    SearchResultPage(
        store: .init(
            initialState: SearchResultReducer.State(x509: .stub)
        ) {
            SearchResultReducer()
        }
    )
}
#endif
