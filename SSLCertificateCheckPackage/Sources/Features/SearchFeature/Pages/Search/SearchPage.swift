//
//  SearchPage.swift
//
//
//  Created by Yuya Oka on 2023/10/13.
//

import ComposableArchitecture
import InfoFeature
import SFSafeSymbols
import SwiftUI

package struct SearchPage: View {
    // MARK: - Properties
    private let store: StoreOf<SearchReducer>

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
                    IfLetStore(store.scope(state: \.info, action: SearchReducer.Action.info)) { store in
                        InfoPage(store: store)
                    }
                }
            )
        })
    }

    // MARK: - Initialize
    package init(
        store: StoreOf<SearchReducer> = Store(initialState: SearchReducer.State()) { SearchReducer() }
    ) {
        self.store = store
    }
}

private extension View {
    func toolbar(_ viewStore: ViewStoreOf<SearchReducer>) -> some View {
        toolbar {
            ToolbarItem(
                placement: .topBarLeading,
                content: {
                    Button(
                        action: {
                            viewStore.send(.openInfo)
                        },
                        label: {
                            Image(systemSymbol: .infoCircle)
                        }
                    )
                }
            )
        }
    }
}

#Preview {
    SearchPage(
        store: Store(
            initialState: SearchReducer.State()
        ) {
            SearchReducer()
        }
    )
}
