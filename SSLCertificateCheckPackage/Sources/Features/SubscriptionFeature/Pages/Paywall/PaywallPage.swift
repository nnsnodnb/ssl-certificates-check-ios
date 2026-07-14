//
//  PaywallPage.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/23.
//

import ComposableArchitecture
import MemberwiseInit
import RevenueCatUI
import SwiftUI

@MemberwiseInit(.package)
public struct PaywallPage: View {
  // MARK: - Properties
  @Init(.package)
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

struct PaywallPage_Previews: PreviewProvider {
  static var previews: some View {
    PaywallPage(
      store: .init(
        initialState: PaywallReducer.State(),
        reducer: {
          PaywallReducer()
        },
      )
    )
  }
}
