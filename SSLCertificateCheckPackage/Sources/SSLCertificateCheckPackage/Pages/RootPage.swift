//
//  RootPage.swift
//
//
//  Created by Yuya Oka on 2023/10/12.
//

import SwiftUI

public struct RootPage: View {
    // MARK: - Body
    public var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }

    // MARK: - Initialize
    public init() {
    }
}

#Preview {
    RootPage()
}
