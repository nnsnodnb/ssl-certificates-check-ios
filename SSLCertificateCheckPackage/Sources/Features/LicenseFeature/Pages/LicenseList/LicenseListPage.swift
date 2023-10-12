//
//  LicenseListPage.swift
//
//
//  Created by Yuya Oka on 2023/10/13.
//

import SwiftUI

package struct LicenseListPage: View {
    // MARK: - Body
    package var body: some View {
        NavigationStack {
            List {
                ForEach(LicensesPlugin.licenses) { license in
                    Button {
                        print(license.name)
                    } label: {
                        Text(license.name)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .navigationTitle("Licenses")
        }
    }

    // MARK: - Initialize
    package init() {
    }
}

#Preview {
    LicenseListPage()
}
