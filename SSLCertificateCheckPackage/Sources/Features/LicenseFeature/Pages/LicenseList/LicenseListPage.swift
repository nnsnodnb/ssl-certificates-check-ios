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
            List {
                ForEach(LicensesPlugin.licenses) { license in
                    Button {
                        print(license.name)
                    } label: {
                        Text(license.name)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .navigationTitle("Licenses")
        })
    }

    // MARK: - Initialize
    package init(store: StoreOf<LicenseListReducer>) {
        self.store = store
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
