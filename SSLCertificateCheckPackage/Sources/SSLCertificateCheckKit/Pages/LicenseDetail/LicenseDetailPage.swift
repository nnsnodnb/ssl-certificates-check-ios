//
//  LicenseDetailPage.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import DependenciesInterfaces
import SwiftUI

public struct LicenseDetailPage: View {
  // MARK: - Properties
  public let license: LicensesPlugin.License

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
      license: LicensesPlugin.licenses[0],
    )
  }
}
