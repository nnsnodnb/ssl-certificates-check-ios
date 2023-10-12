//
//  HomePage.swift
//
//
//  Created by Yuya Oka on 2023/10/13.
//

import SwiftUI

package struct HomePage: View {
    // MARK: - Body
    package var body: some View {
        NavigationStack {
            Text("Hello world")
                .toolbar()
        }
    }

    // MARK: - Initialize
    package init() {
    }
}

private extension View {
    func toolbar() -> some View {
        toolbar {
            ToolbarItem(
                placement: .topBarLeading,
                content: {
                    Button(
                        action: {
                            print("OK")
                        },
                        label: {
                            Image(systemName: "gear")
                        }
                    )
                }
            )
        }
    }
}

#Preview {
    HomePage()
}
