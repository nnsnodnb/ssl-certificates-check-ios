//
//  LicenseListPage.swift
//
//
//  Created by Yuya Oka on 2023/10/13.
//

import ComposableArchitecture
import SwiftUI

public struct LicenseListPage: View {
  // MARK: - Properties
  public let store: StoreOf<LicenseListReducer>

  // MARK: - Body
  public var body: some View {
    list
      .navigationTitle("Licenses")
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
        NavigationLink(
          destination: {
            LicenseDetailPage(license: license)
          },
          label: {
            Text(license.name)
              .foregroundStyle(Color(.label))
              .frame(maxWidth: .infinity, alignment: .leading)
          }
        )
      }
    }
  }
}

#Preview {
  NavigationStack {
    LicenseListPage(
      store: .init(
        initialState: LicenseListReducer.State(),
        reducer: {
          LicenseListReducer()
        },
      ),
    )
  }
}
