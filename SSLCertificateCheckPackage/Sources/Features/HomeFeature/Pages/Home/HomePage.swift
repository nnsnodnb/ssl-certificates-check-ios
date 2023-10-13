//
//  HomePage.swift
//
//
//  Created by Yuya Oka on 2023/10/13.
//

import ComposableArchitecture
import InfoFeature
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
                    .toolbar(viewStore)
            }
            .sheet(
                isPresented: viewStore.binding(
                    get: { $0.info != nil },
                    send: { $0 ? .openInfo : .dismissInfo }
                ),
                content: {
                    IfLetStore(store.scope(state: \.info, action: HomeReducer.Action.info)) { store in
                        InfoPage(store: store)
                    }
                }
            )
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
    func toolbar(_ viewStore: ViewStoreOf<HomeReducer>) -> some View {
        toolbar {
            ToolbarItem(
                placement: .topBarLeading,
                content: {
                    Button(
                        action: {
                            viewStore.send(.openInfo)
                        },
                        label: {
                            Image(systemSymbol: .iCircle)
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
