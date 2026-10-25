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
  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    public var searchHistories: IdentifiedArrayOf<SearchHistory> = .init(uniqueElements: [])
    public var selectedSearchHistoy: SearchHistory?
    @Presents public var searchResult: SearchResultReducer.State?
  }

  // MARK: - Action
  public enum Action {
    case fetchSearchHistory
    case selectSearchHistory(SearchHistory?)
    case deleteSearchHistory(IndexSet)
    case searchResult(PresentationAction<SearchResultReducer.Action>)
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
      case .fetchSearchHistory:
        return .run(
          operation: { send in
            let searchHistories = try await database.fetchSearchHistroies()
            await send(.internalAction(.fetchedSearchHistories(searchHistories)))
          },
        )
      case let .selectSearchHistory(searchHistory):
        state.selectedSearchHistoy = searchHistory
        if let searchHistory {
          state.searchResult = .init(
            domain: searchHistory.domain,
            certificates: .init(uniqueElements: searchHistory.x509),
          )
        } else {
          state.searchResult = nil
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
            await send(.fetchSearchHistory)
          },
        )
      case .searchResult(.dismiss):
        state.selectedSearchHistoy = nil
        return .none
      case .searchResult:
        return .none
      case let .internalAction(.fetchedSearchHistories(searchHistories)):
        state.searchHistories = .init(uniqueElements: searchHistories)
        return .none
      }
    }
    .ifLet(\.$searchResult, action: \.searchResult) {
      SearchResultReducer()
    }
  }
}

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
    .fullScreenCover(item: $store.scope(\.searchResult, action: \.searchResult)) { store in
      SearchResultPage(store: store)
    }
    .task {
      store.send(.fetchSearchHistory)
    }
  }

  @ViewBuilder private var content: some View {
    if store.searchHistories.isEmpty {
      emptyView
    } else {
      list
    }
  }

  private var emptyView: some View {
    ContentUnavailableView("No search histories", systemSymbol: .trayFullFill)
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
