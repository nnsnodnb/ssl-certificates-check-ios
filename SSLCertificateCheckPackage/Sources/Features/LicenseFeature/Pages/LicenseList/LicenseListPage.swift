//
//  LicenseListPage.swift
//
//
//  Created by Yuya Oka on 2023/10/13.
//

import ClientDependencies
import ComposableArchitecture
import SwiftUI

package struct LicenseListPage: View {
    // MARK: - Properties
    private let store: StoreOf<LicenseListReducer>

    // MARK: - Body
    package var body: some View {
        list
            .navigationTitle("Licenses")
            .task(priority: .high) {
                guard store.licenses.isEmpty else { return }
                store.send(.fetchLicenses)
            }
    }

    // MARK: - Initialize
    package init(store: StoreOf<LicenseListReducer>) {
        self.store = store
    }
}

// MARK: - Private method
private extension LicenseListPage {
    var list: some View {
        List {
            ForEach(store.licenses) { license in
                NavigationLink(
                    destination: {
                        LicenseDetailPage(license: license)
                    },
                    label: {
                        Text(license.name)
                            .foregroundStyle(Color(.label))
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
