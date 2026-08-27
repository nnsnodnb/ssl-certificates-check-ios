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
public struct SearchResultReducer {
  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    // MARK: - Properties
    public let certificates: IdentifiedArrayOf<X509>
  }

  // MARK: - Action
  public enum Action: Equatable {
    case selectCertificate(X509)
  }

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .selectCertificate:
        return .none
      }
    }
  }
}
