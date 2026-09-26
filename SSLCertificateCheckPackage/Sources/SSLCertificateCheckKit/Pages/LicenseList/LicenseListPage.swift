//
//  LicenseListPage.swift
//
//
//  Created by Yuya Oka on 2023/10/13.
//

import ComposableArchitecture
import DependenciesInterfaces
import Logger
import SwiftUI

@Reducer
public struct LicenseListReducer: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    // MARK: - Properties
    public var licenses: IdentifiedArrayOf<LicensesPlugin.License> = []
  }

  // MARK: - Action
  public enum Action: Equatable {
    case fetchLicenses
    case fetchLicensesResponse(Result<[LicensesPlugin.License], Error>)
    case pushLicenseDetail(LicensesPlugin.License)
    case delegate(Delegate)

    // MARK: - Delegate
    @CasePathable
    public enum Delegate: Equatable {
      case pushLicenseDetail(LicensesPlugin.License)
    }

    // MARK: - Error
    @CasePathable
    public enum Error: Swift::Error {
      case fetchLicenses
    }
  }

  // MARK: - Properties
  @Dependency(\.license)
  private var license

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchLicenses:
        return .run(
          operation: { send in
            let licenses = try await license.fetchLicenses()
            await send(.fetchLicensesResponse(.success(licenses)))
          },
          catch: { error, send in
            await send(.fetchLicensesResponse(.failure(.fetchLicenses)))
            Logger.error("\(error)")
          }
        )
      case let .fetchLicensesResponse(.success(licenses)):
        state.licenses = .init(uniqueElements: licenses)
        return .none
      case .fetchLicensesResponse(.failure):
        return .none
      case let .pushLicenseDetail(license):
        return .send(.delegate(.pushLicenseDetail(license)))
      case .delegate:
        return .none
      }
    }
  }
}

public struct LicenseListPage: View {
  // MARK: - Properties
  public let store: StoreOf<LicenseListReducer>

  // MARK: - Body
  public var body: some View {
    list
      .navigationTitle("Licenses")
      .navigationScrollEdgeEffectSoft()
      .interactiveDismissDisabled(true)
      .task(priority: .high) {
        guard store.licenses.isEmpty else { return }
        store.send(.fetchLicenses)
      }
  }
}

// MARK: - Private method
private extension LicenseListPage {
  var list: some View {
    List {
      ForEach(store.licenses) { license in
        Button(
          action: {
            store.send(.pushLicenseDetail(license))
          },
          label: {
            Text(license.name)
              .foregroundStyle(Color(.label))
              .frame(maxWidth: .infinity, alignment: .leading)
          },
        )
      }
    }
  }
}

#Preview {
  NavigationStack(
    root: {
      LicenseListPage(
        store: .init(
          initialState: LicenseListReducer.State(),
          reducer: {
            LicenseListReducer()
          },
        ),
      )
    },
  )
}
