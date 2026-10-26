//
//  MainPage.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/10/26.
//

import ComposableArchitecture
import DependenciesInterfaces
import SwiftUI

@Reducer
public struct MainReducer: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    public let version: String
    public var search: SearchReducer.State = .init()
    public var historyList: HistoryListReducer.State = .init()
    public var info: InfoReducer.State?
    @Shared(.inMemory(.isPremiumSubscriptionIsActive))
    public var isPremiumActive = false
  }

  // MARK: - Action
  public enum Action {
    case onAppear
    case search(SearchReducer.Action)
    case historyList(HistoryListReducer.Action)
    case info(InfoReducer.Action)
    case internalAction(InternalAction)

    // MARK: - InternalAction
    @CasePathable
    public enum InternalAction {
      case setIsPremiumActive(Bool)
    }
  }

  // MARK: - Dependency
  @Dependency(\.revenueCat)
  private var revenueCat

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Scope(\.search, action: \.search) {
      SearchReducer()
    }
    Scope(\.historyList, action: \.historyList) {
      HistoryListReducer()
    }
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.info = .init(version: state.version)
        return .run(
          operation: { send in
            for try await isActive in try await revenueCat.isPremiumActiveStream() {
              await send(.internalAction(.setIsPremiumActive(isActive)))
            }
          },
        )
      case .search:
        return .none
      case .historyList:
        return .none
      case .info:
        return .none
      case let .internalAction(.setIsPremiumActive(isActive)):
        state.$isPremiumActive.withLock { $0 = isActive }
        return .none
      }
    }
    .ifLet(\.info, action: \.info) {
      InfoReducer()
    }
  }
}

public struct MainPage: View {
  // MARK: - Properties
  public let store: StoreOf<MainReducer>

  // MARK: - Body
  public var body: some View {
    if let infoStore = store.scope(\.info, action: \.info) {
      TabView {
        Tab("Search", systemSymbol: .magnifyingglass) {
          SearchPage(store: store.scope(\.search, action: \.search))
        }
        Tab("History", systemSymbol: .trayFullFill) {
          HistoryListPage(store: store.scope(\.historyList, action: \.historyList))
        }
        Tab("Info", systemSymbol: .info) {
          InfoPage(store: infoStore)
        }
      }
    } else {
      Color(.systemBackground)
        .task {
          store.send(.onAppear)
        }
    }
  }
}

#Preview {
  MainPage(
    store: .init(
      initialState: MainReducer.State(version: "1.0.0-preview"),
      reducer: {
        MainReducer()
      },
    ),
  )
}
