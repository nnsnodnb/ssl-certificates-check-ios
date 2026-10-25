//
//  RootPage.swift
//
//
//  Created by Yuya Oka on 2023/10/12.
//

import ComposableArchitecture
import Dependencies
import DependenciesInterfaces
import IssueReporting
import MemberwiseInit
import SwiftUI

@Reducer
@MemberwiseInit(.public)
public struct RootReducer: Sendable {
  // MARK: - State
  @ObservableState
  @MemberwiseInit(.public)
  public struct State: Equatable {
    @Init(.public, default: nil)
    public var checkSubscription: CheckSubscriptionReducer.State?
    @Init(.public, default: nil)
    public var consent: ConsentReducer.State?
    @Init(.public, default: nil)
    public var search: SearchReducer.State?
    @Init(.public, default: nil)
    public var historyList: HistoryListReducer.State?
    @Init(.public, default: nil)
    public var info: InfoReducer.State?
  }

  // MARK: - Action
  public enum Action {
    case showCheckSubscription
    case showConsent
    case checkSubscription(CheckSubscriptionReducer.Action)
    case consent(ConsentReducer.Action)
    case search(SearchReducer.Action)
    case historyList(HistoryListReducer.Action)
    case info(InfoReducer.Action)
  }

  // MARK: - Dependency
  @Dependency(\.bundle)
  private var bundle

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .showCheckSubscription:
        state.checkSubscription = .init()
        return .none
      case .showConsent:
        state.checkSubscription = nil
        state.consent = .init()
        return .none
      case .checkSubscription(.delegate(.completed)):
        return .send(.showConsent)
      case .checkSubscription:
        return .none
      case .consent(.delegate(.completedConsent)):
        state.consent = nil
        state.search = .init()
        state.historyList = .init()
        let version = bundle.shortVersionString()
        state.info = .init(version: "v\(version)")
        return .none
      case .consent:
        return .none
      case .search:
        return .none
      case .historyList:
        return .none
      case .info:
        return .none
      }
    }
    // FIXME: Destinationにする
    .ifLet(\.checkSubscription, action: \.checkSubscription) {
      CheckSubscriptionReducer()
    }
    .ifLet(\.consent, action: \.consent) {
      ConsentReducer()
    }
    .ifLet(\.search, action: \.search) {
      SearchReducer()
    }
    .ifLet(\.historyList, action: \.historyList) {
      HistoryListReducer()
    }
    .ifLet(\.info, action: \.info) {
      InfoReducer()
    }
  }
}

@MemberwiseInit(.public)
public struct RootPage: View {
  // MARK: - Properties
  @Init(.public)
  public let store: StoreOf<RootReducer>

  // MARK: - Dependencies
  @Dependency(\.consentInformation)
  private var consentInformation

  // MARK: - Body
  public var body: some View {
    if isTesting {
      Text("Run Testing")
    } else if let store = store.scope(\.checkSubscription, action: \.checkSubscription) {
      CheckSubscriptionPage(store: store)
    } else if let store = store.scope(\.consent, action: \.consent) {
      ConsentPage(store: store)
    } else if let searchStore = store.scope(\.search, action: \.search),
              let historyListStore = store.scope(\.historyList, action: \.historyList),
              let infoStore = store.scope(\.info, action: \.info) {
      TabView {
        Tab("Search", systemSymbol: .magnifyingglass) {
          SearchPage(store: searchStore)
        }
        Tab("History", systemSymbol: .trayFullFill) {
          HistoryListPage(store: historyListStore)
        }
        Tab("Info", systemSymbol: .info) {
          InfoPage(store: infoStore)
        }
      }
    } else {
      initializeView
    }
  }

  private var initializeView: some View {
    Color(.systemBackground)
      .overlay {
        ProgressView()
          .progressViewStyle(.circular)
      }
      .task {
        store.send(.showCheckSubscription)
      }
  }

  @ViewBuilder private var consentPage: some View {
    if let store = store.scope(\.consent, action: \.consent) {
      ConsentPage(store: store)
    }
  }
}

struct RootPage_Previews: PreviewProvider {
  static var previews: some View {
    RootPage(
      store: .init(
        initialState: RootReducer.State(),
        reducer: {
          RootReducer()
        },
        withDependencies: {
          $0.adUnitID.requestStartRewardAdUnitID = { "ca-app-pub-3940256099942544/6978759866" }
          $0.adUnitID.searchPageBottomBannerAdUnitID = { "ca-app-pub-3940256099942544/2435281174" }
        },
      ),
    )
  }
}
