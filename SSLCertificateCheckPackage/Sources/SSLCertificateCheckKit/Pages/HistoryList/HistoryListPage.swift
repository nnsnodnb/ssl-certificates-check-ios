//
//  SwiftUIView.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/10/25.
//

import ComposableArchitecture
import Database
import DependenciesInterfaces
import SwiftUI

@Reducer
public struct HistoryListReducer: Sendable {
  // MARK: - Destination
  @Reducer
  public enum Destination {
    case searchResult(SearchResultReducer)
    case paywall(PaywallReducer)
  }

  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    // MARK: - ContentState
    public enum ContentState {
      case needSubscription
      case empty
      case list
    }

    // MARK: - Properties
    public var contentState: ContentState
    public var searchHistories: IdentifiedArrayOf<SearchHistory> = .init(uniqueElements: [])
    public var selectedSearchHistoy: SearchHistory?
    @Presents public var destination: Destination.State?
    @Shared(.inMemory(.isPremiumSubscriptionIsActive))
    public var isPremiumActive = false

    // MARK: - Initialize
    public init(
      searchHistories: IdentifiedArrayOf<SearchHistory> = .init(uniqueElements: []),
      selectedSearchHistoy: SearchHistory? = nil,
      destination: Destination.State? = nil,
      isPremiumActive: Bool = false,
    ) {
      self.contentState = isPremiumActive ? .empty : .needSubscription
      self.searchHistories = searchHistories
      self.selectedSearchHistoy = selectedSearchHistoy
      self.destination = destination
      self.$isPremiumActive.withLock { $0 = isPremiumActive }
    }
  }

  // MARK: - Action
  public enum Action {
    case fetchSearchHistories
    case selectSearchHistory(SearchHistory?)
    case deleteSearchHistory(IndexSet)
    case showPaywall
    case destination(PresentationAction<Destination.Action>)
    case internalAction(InternalAction)

    // MARK: - InternalAction
    @CasePathable
    public enum InternalAction {
      case fetchedSearchHistories([SearchHistory])
    }
  }

  // MARK: - Dependency
  @Dependency(\.database)
  private var database

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchSearchHistories:
        guard state.isPremiumActive else { return .none }
        return .run(
          operation: { send in
            let searchHistories = try await database.fetchSearchHistroies()
            await send(.internalAction(.fetchedSearchHistories(searchHistories)))
          },
        )
      case let .selectSearchHistory(searchHistory):
        guard state.isPremiumActive else { return .none }
        state.selectedSearchHistoy = searchHistory
        if let searchHistory {
          state.destination = .searchResult(
            .init(
              domain: searchHistory.domain,
              certificates: .init(uniqueElements: searchHistory.x509),
            )
          )
        } else {
          state.destination = nil
        }
        return .none
      case let .deleteSearchHistory(indexSet):
        return .run(
          operation: { [searchHistories = state.searchHistories] send in
            for index in indexSet {
              guard let searchHistory = searchHistories[safe: index] else {
                continue
              }
              try await database.deleteSearchHistory(searchHistory)
            }
            await send(.fetchSearchHistories)
          },
        )
      case .showPaywall:
        state.destination = .paywall(.init())
        return .none
      case .destination(.dismiss):
        state.selectedSearchHistoy = nil
        return .none
      case .destination:
        return .none
      case let .internalAction(.fetchedSearchHistories(searchHistories)):
        state.searchHistories = .init(uniqueElements: searchHistories)
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination)
  }
}

// MARK: - HistoryListReducer.Destination.State Equatable
extension HistoryListReducer.Destination.State: Equatable {}

public struct HistoryListPage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<HistoryListReducer>

  private static let dateFormatter: DateFormatter = {
    @Dependency(\.calendar)
    var calendar
    @Dependency(\.timeZone)
    var timeZone

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    dateFormatter.calendar = calendar
    dateFormatter.timeZone = timeZone
    dateFormatter.locale = .init(identifier: "en_US_POSIX")
    return dateFormatter
  }()

  // MARK: - Body
  public var body: some View {
    NavigationStack(
      root: {
        content
          .navigationTitle("Search histories")
          .toolbarTitleDisplayMode(.inlineLarge)
      },
    )
    .fullScreenCover(item: $store.scope(\.destination, action: \.destination).searchResult) { store in
      SearchResultPage(store: store)
    }
    .sheet(item: $store.scope(\.destination, action: \.destination).paywall) { store in
      PaywallPage(store: store)
    }
    .task {
      store.send(.fetchSearchHistories)
    }
  }

  @ViewBuilder private var content: some View {
    switch store.contentState {
    case .needSubscription:
      needSubscriptionView
    case .empty:
      emptyView
    case .list:
      list
    }
  }

  private var needSubscriptionView: some View {
    ContentUnavailableView(
      label: {
        VStack(alignment: .center, spacing: 24) {
          VStack(alignment: .center, spacing: 16) {
            Image(systemSymbol: .crownFill)
              .resizable()
              .scaledToFit()
              .frame(width: 48, height: 48)
              .foregroundStyle(Color.yellow)
            Text("Need subscribe Premium plan")
              .font(.system(size: 18, weight: .bold))
          }
          Button(
            action: {
              store.send(.showPaywall)
            },
            label: {
              Text("Subscribe Premium")
            },
          )
          .modifier {
            if #available(iOS 26.0, *) {
              $0.buttonStyle(.glassProminent)
            } else {
              $0.buttonStyle(.borderedProminent)
            }
          }
        }
      },
    )
    .background(Color(UIColor.systemGroupedBackground))
  }

  private var emptyView: some View {
    ContentUnavailableView("No search histories", systemSymbol: .trayFullFill)
      .background(Color(UIColor.systemGroupedBackground))
  }

  private var list: some View {
    List(selection: $store.selectedSearchHistoy.sending(\.selectSearchHistory)) {
      ForEach(store.searchHistories, id: \.self) { searchHistory in
        row(searchHistory: searchHistory)
      }
      .onDelete {
        store.send(.deleteSearchHistory($0))
      }
    }
    .listStyle(.insetGrouped)
  }

  private func row(searchHistory: SearchHistory) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(searchHistory.domain)
      HStack(alignment: .center, spacing: 8) {
        if let x509 = searchHistory.x509.first {
          Image(systemSymbol: x509.isValid ? .checkmarkCircleFill : .xmarkCircleFill)
            .resizable()
            .scaledToFit()
            .frame(width: 18, height: 18)
            .foregroundStyle(x509.isValid ? Color.green : Color.red)
          Text("This certificate is \(x509.isValid ? "" : "in")valid.")
            .font(.system(size: 14))
        }
      }
      Text(Self.dateFormatter.string(from: searchHistory.createdAt))
        .font(.system(size: 12))
        .foregroundStyle(Color.gray.opacity(0.8))
    }
  }
}

#Preview {
  HistoryListPage(
    store: .init(
      initialState: HistoryListReducer.State(),
      reducer: {
        HistoryListReducer()
      },
    ),
  )
}
