//
//  ListRowChevronRight.swift
//  
//
//  Created by Yuya Oka on 2023/10/14.
//

import SFSafeSymbols
import SwiftUI

package struct ListRowChevronRight: View {
    // MARK: - Body
    package var body: some View {
        Image(systemSymbol: .chevronRight)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Color.secondary)
            .opacity(0.5)
    }

    // MARK: - Initialize
    package init() {
    }
}

#Preview {
    ListRowChevronRight()
}
