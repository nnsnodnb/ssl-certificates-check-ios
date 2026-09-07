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
    public let domain: String
    public let certificates: IdentifiedArrayOf<X509>
  }

  // MARK: - Action
  public enum Action {
    case selectCertificate(X509)
    case delegate(Delegate)

    // MARK: - Delegate
    @CasePathable
    public enum Delegate {
      case goSearchResultDetail(X509)
    }
  }

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case let .selectCertificate(x509):
        return .send(.delegate(.goSearchResultDetail(x509)))
      case .delegate:
        return .none
      }
    }
  }
}
