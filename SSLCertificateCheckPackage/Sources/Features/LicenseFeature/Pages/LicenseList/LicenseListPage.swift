//
//  LicenseListPage.swift
//
//
//  Created by Yuya Oka on 2023/10/13.
//

import ComposableArchitecture
import SwiftUI

package struct LicenseListPage: View {
    // MARK: - Properties
    private let store: StoreOf<LicenseListReducer>

    // MARK: - Body
    package var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            list(viewStore)
                .navigationTitle("Licenses")
                .task(priority: .high) {
                    guard viewStore.licenses.isEmpty else { return }
                    viewStore.send(.fetchLicenses)
                }
        })
    }

    // MARK: - Initialize
    package init(store: StoreOf<LicenseListReducer>) {
        self.store = store
    }
}

// MARK: - Private method
@MainActor
private extension LicenseListPage {
    func list(_ viewStore: ViewStoreOf<LicenseListReducer>) -> some View {
        List {
            ForEach(viewStore.licenses) { license in
                NavigationLink(
                    destination: {
                        LicenseDetailPage(license: license)
                    },
                    label: {
                        Text(license.name)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        LicenseListPage(
            store: Store(
                initialState: LicenseListReducer.State()
            ) {
                LicenseListReducer()
            }
        )
    }
}
