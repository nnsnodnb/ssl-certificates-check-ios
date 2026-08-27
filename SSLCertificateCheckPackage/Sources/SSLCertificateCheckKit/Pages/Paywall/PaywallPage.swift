//
//  PaywallPage.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/23.
//

import ComposableArchitecture
import RevenueCatUI
import SwiftUI

public struct PaywallPage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<PaywallReducer>

  public var body: some View {
    PaywallView()
      .onRestoreCompleted { customerInfo in
        store.send(.restoreCompleted(customerInfo))
      }
      .onRestoreFailure { _ in
        store.send(.restoreFailure)
      }
      .alert($store.scope(\.$alert, action: \.alert))
  }
}

#Preview {
  PaywallPage(
    store: .init(
      initialState: PaywallReducer.State(),
      reducer: {
        PaywallReducer()
      },
    ),
  )
}
