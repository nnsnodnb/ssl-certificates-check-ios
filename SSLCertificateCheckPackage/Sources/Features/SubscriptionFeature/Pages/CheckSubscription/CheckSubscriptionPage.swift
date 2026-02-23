//
//  SwiftUIView.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/21.
//

import ComposableArchitecture
import SwiftUI

package struct CheckSubscriptionPage: View {
    // MARK: - Properties
    let store: StoreOf<CheckSubscriptionReducer>

    package var body: some View {
        Color(UIColor.systemBackground.withAlphaComponent(0.000001))
            .ignoresSafeArea(.all)
            .onAppear {
                store.send(.onAppear)
            }
    }

    // MARK: - Initialize
    package init(store: StoreOf<CheckSubscriptionReducer>) {
        self.store = store
    }
}

#Preview {
    CheckSubscriptionPage(
        store: .init(
            initialState: CheckSubscriptionReducer.State(),
            reducer: {
                CheckSubscriptionReducer()
            },
        )
    )
}
