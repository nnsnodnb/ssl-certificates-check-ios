//
//  LicenseDetailPage.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import ComposableArchitecture
import DependenciesInterfaces
import SwiftUI

@Reducer
public struct LicenseDetailReducer: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    public let license: LicensesPlugin.License
  }

  // MARK: - Action
  public enum Action {
  }

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    EmptyReducer()
  }
}

public struct LicenseDetailPage: View {
  // MARK: - Properties
  public let store: StoreOf<LicenseDetailReducer>

  // MARK: - Body
  public var body: some View {
    Form {
      if let licenseText = store.license.licenseText {
        ScrollView {
          Text(licenseText)
            .font(.system(size: 14))
            .foregroundStyle(.secondary)
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
      }
    }
    .formStyle(.columns)
    .navigationTitle(store.license.name)
    .navigationScrollEdgeEffectSoft()
  }
}

#Preview {
  NavigationStack(
    root: {
      LicenseDetailPage(
        store: .init(
          initialState: LicenseDetailReducer.State(
            license: LicensesPlugin.licenses[0],
          ),
          reducer: {
            LicenseDetailReducer()
          },
        ),
      )
    },
  )
}
