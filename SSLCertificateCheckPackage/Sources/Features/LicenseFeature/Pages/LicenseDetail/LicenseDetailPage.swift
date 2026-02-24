//
//  LicenseDetailPage.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import ClientDependencies
import MemberwiseInit
import SwiftUI

@MemberwiseInit
package struct LicenseDetailPage: View {
  // MARK: - Properties
  @Init(.package)
  private let license: License

  // MARK: - Body
  package var body: some View {
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

struct LicenseDetailPage_Previews: PreviewProvider {
  static var previews: some View {
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
}
