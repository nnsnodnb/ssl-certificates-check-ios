//
//  SearchResultReducer.swift
//
//
//  Created by Yuya Oka on 2023/10/21.
//

import ComposableArchitecture
import Foundation
import X509Parser

@Reducer
package struct SearchResultReducer {
  // MARK: - State
  @ObservableState
  package struct State: Equatable {
    // MARK: - Properties
    package let certificates: IdentifiedArrayOf<X509>
  }

  // MARK: - Action
  package enum Action: Equatable {
    case selectCertificate(X509)
  }

  // MARK: - Body
  package var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .selectCertificate:
        return .none
      }
    }
  }
}
