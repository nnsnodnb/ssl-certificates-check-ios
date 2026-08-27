//
//  CheckSubscriptionPage.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/21.
//

import ComposableArchitecture
import SwiftUI

public struct CheckSubscriptionPage: View {
  // MARK: - Properties
  let store: StoreOf<CheckSubscriptionReducer>

  public var body: some View {
    Color(UIColor.systemBackground.withAlphaComponent(0.000001))
      .ignoresSafeArea(.all)
      .overlay {
        if !store.wasSendCompleted {
          ProgressView()
            .progressViewStyle(.circular)
            .scaleEffect(2)
        }
      }
      .onAppear {
        store.send(.onAppear)
      }
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
