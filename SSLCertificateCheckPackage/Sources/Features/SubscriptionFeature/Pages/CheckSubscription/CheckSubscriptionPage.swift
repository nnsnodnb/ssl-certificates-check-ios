//
//  CheckSubscriptionPage.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/21.
//

import ComposableArchitecture
import MemberwiseInit
import SwiftUI

@MemberwiseInit(.package)
package struct CheckSubscriptionPage: View {
  // MARK: - Properties
  @Init(.package)
  let store: StoreOf<CheckSubscriptionReducer>

  package var body: some View {
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

struct CheckSubscriptionPage_Previews: PreviewProvider {
  static var previews: some View {
    CheckSubscriptionPage(
      store: .init(
        initialState: CheckSubscriptionReducer.State(),
        reducer: {
          CheckSubscriptionReducer()
        },
      )
    )
  }
}
