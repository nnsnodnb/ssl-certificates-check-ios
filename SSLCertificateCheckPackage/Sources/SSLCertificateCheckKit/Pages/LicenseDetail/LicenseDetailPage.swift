//
//  LicenseDetailPage.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import ClientDependencies
import SwiftUI

public struct LicenseDetailPage: View {
  // MARK: - Properties
  public let license: License

  // MARK: - Body
  public var body: some View {
    Form {
      if let licenseText = license.licenseText {
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
    .navigationTitle(license.name)
  }
}

#Preview {
  NavigationStack {
    LicenseDetailPage(
      license: .init(
        id: "dummy",
        name: "Dummy",
        licenseText: "Dummy license text"
      )
    )
  }
}
