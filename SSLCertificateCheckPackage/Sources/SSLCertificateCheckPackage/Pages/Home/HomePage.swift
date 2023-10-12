//
//  HomePage.swift
//
//
//  Created by Yuya Oka on 2023/10/13.
//

import SwiftUI

struct HomePage: View {
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Text("Hello world")
                .toolbar()
        }
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
