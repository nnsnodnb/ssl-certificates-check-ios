//
//  HomePage.swift
//
//
//  Created by Yuya Oka on 2023/10/13.
//

import ComposableArchitecture
import SFSafeSymbols
import SwiftUI

package struct HomePage: View {
    // MARK: - Properties
    package let store: StoreOf<HomeReducer>

    // MARK: - Body
    package var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            NavigationStack {
                Text("Hello world")
                    .toolbar()
            }
        })
    }

    // MARK: - Initialize
    package init(
        store: StoreOf<HomeReducer> = Store(initialState: HomeReducer.State()) { HomeReducer() }
    ) {
        self.store = store
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
                            Image(systemSymbol: .gear)
                        }
                    )
                }
            )
        }
    }
}

#Preview {
    HomePage(
        store: Store(
            initialState: HomeReducer.State()
        ) {
            HomeReducer()
        }
    )
}
