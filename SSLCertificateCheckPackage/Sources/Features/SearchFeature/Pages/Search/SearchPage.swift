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

    @FocusState private var isFocused: Bool

    // MARK: - Body
    package var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            NavigationStack(
                path: viewStore.binding(
                    get: \.destinations,
                    send: SearchReducer.Action.navigationPathChanged
                ),
                root: {
                    form(viewStore)
                        .navigationTitle("Check TLS/SSL Certificates")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar(
                            viewStore,
                            keyboardClose: {
                                isFocused = false
                            }
                        )
                        .navigationDestination()
                }
            )
            .sheet(store: store, viewStore)
            .alert(store: store.scope(state: \.$alert, action: SearchReducer.Action.alert))
        })
    }

    // MARK: - Initialize
    package init(
        store: StoreOf<SearchReducer> = Store(initialState: SearchReducer.State()) { SearchReducer() }
    ) {
        self.store = store
    }
}

// MARK: - Private method
private extension SearchPage {
    func form(_ viewStore: ViewStoreOf<SearchReducer>) -> some View {
        Form {
            HStack(alignment: .center, spacing: 0) {
                Text("https://")
                    .padding(.horizontal, 8)
                Divider()
                TextField(
                    "example.com",
                    text: viewStore.binding(
                        get: \.text,
                        send: SearchReducer.Action.textChanged
                    )
                )
                .keyboardType(.URL)
                .textCase(.lowercase)
                .focused($isFocused)
                .padding(.horizontal, 8)
            }
        }
        .overlay {
            if viewStore.isLoading {
                Color.gray.opacity(0.8)
                    .overlay {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(x: 2, y: 2, anchor: .center)
                    }
                    .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}

private extension View {
    func toolbar(_ viewStore: ViewStoreOf<SearchReducer>, keyboardClose: @escaping () -> Void) -> some View {
        toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(
                    action: {
                        viewStore.send(.openInfo)
                    },
                    label: {
                        Image(systemSymbol: .infoCircle)
                    }
                )
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: {
                        keyboardClose()
                        viewStore.send(.search)
                    },
                    label: {
                        Image(systemSymbol: .magnifyingglassCircle)
                            .bold()
                            .disabled(viewStore.searchButtonDisabled)
                    }
                )
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(action: keyboardClose) {
                    Text("Close")
                        .bold()
                }
                .padding(.trailing, 8)
            }
        }
    }

    func navigationDestination() -> some View {
        navigationDestination(
            for: SearchReducer.State.Destination.self,
            destination: { destination in
                switch destination {
                case let .searchResult(x509):
                    SearchResultPage(x509: x509)
                }
            }
        )
    }

    func sheet(store: StoreOf<SearchReducer>, _ viewStore: ViewStoreOf<SearchReducer>) -> some View {
        sheet(
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
