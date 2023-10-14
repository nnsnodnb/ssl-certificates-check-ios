//
//  RootPage.swift
//
//
//  Created by Yuya Oka on 2023/10/12.
//

import SearchFeature
import SwiftUI
import XCTestDynamicOverlay

public struct RootPage: View {
    // MARK: - Body
    public var body: some View {
        if _XCTIsTesting {
            Text("Run Testing")
        } else {
            SearchPage()
        }
    }

    // MARK: - Initialize
    public init() {
    }
}

#Preview {
    RootPage()
}
