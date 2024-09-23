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

package struct SearchResultPage: View {
    // MARK: - Properties
    package let store: StoreOf<SearchResultReducer>

    // MARK: - Body
    package var body: some View {
        WithPerceptionTracking {
            List {
                ForEach(store.certificates) { certificate in
                    if let commonName = certificate.subject.commonName {
                        row(commonName: commonName) {
                            store.send(.selectCertificate(certificate), animation: .default)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Private method
private extension SearchResultPage {
    func row(commonName: String, action: @escaping () -> Void) -> some View {
        HStack(alignment: .center, spacing: 0) {
            Button(
                action: action,
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

#if DEBUG
#Preview {
    SearchResultPage(
        store: .init(
            initialState: SearchResultReducer.State(
                certificates: .init(
                    uniqueElements: [.stub]
                )
            )
        ) {
            SearchResultReducer()
        }
    )
}
#endif
