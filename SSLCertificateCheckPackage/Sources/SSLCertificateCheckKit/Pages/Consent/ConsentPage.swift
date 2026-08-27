//
//  ConsentPage.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/17.
//

import ComposableArchitecture
import SwiftUI

public struct ConsentPage: View {
  // MARK: - Properties
  public let store: StoreOf<ConsentReducer>

  // MARK: - Body
  public var body: some View {
    Color(UIColor.systemBackground.withAlphaComponent(0.000001))
      .ignoresSafeArea(.all)
      .onAppear {
        store.send(.showConsent)
      }
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
