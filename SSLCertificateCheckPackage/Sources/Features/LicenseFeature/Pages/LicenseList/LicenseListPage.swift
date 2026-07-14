//
//  LicenseListPage.swift
//
//
//  Created by Yuya Oka on 2023/10/13.
//

import ClientDependencies
import ComposableArchitecture
import MemberwiseInit
import SwiftUI

@MemberwiseInit(.public)
public struct LicenseListPage: View {
  // MARK: - Properties
  @Init(.public)
  private let store: StoreOf<LicenseListReducer>

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

struct LicenseListPage_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      LicenseListPage(
        store: Store(
          initialState: LicenseListReducer.State()
        ) {
          LicenseListReducer()
        }
      )
    }
  }
}
