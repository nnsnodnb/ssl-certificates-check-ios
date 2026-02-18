//
//  ConsentPage.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/17.
//

import ComposableArchitecture
import SwiftUI

package struct ConsentPage: View {
    // MARK: - Properties
    let store: StoreOf<ConsentReducer>

    package var body: some View {
        Color(UIColor.systemBackground.withAlphaComponent(0.000001))
            .ignoresSafeArea(.all)
            .onAppear {
                store.send(.showConsent)
            }
    }

    // MARK: - Initialize
    package init(store: StoreOf<ConsentReducer>) {
        self.store = store
    }
}

#Preview {
    ConsentPage(
        store: .init(
            initialState: .init(),
            reducer: {
                ConsentReducer()
            },
        )
    )
}
