//
//  LicenseDetailPage.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import SwiftUI

@MainActor
package struct LicenseDetailPage: View {
    // MARK: - Properties
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

    // MARK: - Initialize
    package init(license: License) {
        self.license = license
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
