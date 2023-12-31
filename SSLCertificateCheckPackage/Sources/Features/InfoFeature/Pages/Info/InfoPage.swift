//
//  SwiftUIView.swift
//  
//
//  Created by Yuya Oka on 2023/10/13.
//

import ComposableArchitecture
import LicenseFeature
import SafariUI
import SFSafeSymbols
import SwiftUI
import UIComponents

@MainActor
package struct InfoPage: View {
    // MARK: - Properties
    private let store: StoreOf<InfoReducer>

    // MARK: - Body
    package var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            NavigationStack(
                path: viewStore.binding(
                    get: \.destinations,
                    send: InfoReducer.Action.navigationPathChanged
                ),
                root: {
                    form(viewStore)
                        .navigationTitle("App Information")
                        .navigationDestination(store: store)
                        .toolbar(viewStore)
                        .safari(viewStore)
                }
            )
            .interactiveDismissDisabled(viewStore.interactiveDismissDisabled)
            .alert(store: store.scope(state: \.$alert, action: \.alert))
        })
    }

    // MARK: - Initialize
    package init(store: StoreOf<InfoReducer>) {
        self.store = store
    }
}

// MARK: - Private method
@MainActor
private extension InfoPage {
    func form(_ viewStore: ViewStoreOf<InfoReducer>) -> some View {
        Form {
            firstSection(viewStore)
            secondSection(viewStore)
        }
    }

    func firstSection(_ viewStore: ViewStoreOf<InfoReducer>) -> some View {
        Section {
            buttonRow(
                action: {
                    viewStore.send(.safari(.gitHub))
                },
                image: {
                    Image(.icGithub)
                        .resizable()
                },
                title: "Source code"
            )
            buttonRow(
                action: {
                    viewStore.send(.safari(.xTwitter))
                },
                image: {
                    Image(.icXTwitetr)
                        .resizable()
                },
                title: "Contact developer"
            )
        }
    }

    func secondSection(_ viewStore: ViewStoreOf<InfoReducer>) -> some View {
        Section {
            buttonRow(
                action: {
                    viewStore.send(.openAppReview)
                },
                image: {
                    Image(systemSymbol: .starBubble)
                        .resizable()
                        .foregroundStyle(.purple)
                },
                title: "Review App"
            )
            buttonRow(
                action: {
                    viewStore.send(.pushLicenseList)
                },
                image: {
                    Image(systemSymbol: .listBulletRectangleFill)
                        .resizable()
                        .foregroundStyle(.green)
                },
                title: "Licenses"
            )
            HStack(alignment: .center, spacing: 8) {
                HStack(alignment: .center, spacing: 12) {
                    Image(systemSymbol: .tagFill)
                        .resizable()
                        .foregroundStyle(.yellow)
                        .frame(width: 18, height: 18)
                    Text("Version")
                        .foregroundStyle(.primary)
                }
                Spacer()
                Text(viewStore.version)
                    .foregroundStyle(.secondary)
            }
            HStack(alignment: .center, spacing: 12) {
                Image(systemSymbol: .swift)
                    .resizable()
                    .foregroundStyle(.orange)
                    .frame(width: 18, height: 18)
                Text("Developed by SwiftUI")
                    .foregroundStyle(.primary)
            }
        }
    }

    private func buttonRow(
        action: @escaping () -> Void,
        image: () -> some View,
        title: String
    ) -> some View {
        Button(
            action: action,
            label: {
                HStack {
                    HStack(spacing: 12) {
                        image()
                            .frame(width: 18, height: 18)
                        Text(title)
                            .foregroundStyle(Color.primary)
                    }
                    Spacer()
                    ListRowChevronRight()
                }
            }
        )
    }
}

@MainActor
private extension View {
    func toolbar(_ viewStore: ViewStoreOf<InfoReducer>) -> some View {
        toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(
                    action: {
                        viewStore.send(.dismiss)
                    },
                    label: {
                        Image(systemSymbol: .xmark)
                    }
                )
            }
        }
    }

    func navigationDestination(store: StoreOf<InfoReducer>) -> some View {
        navigationDestination(for: InfoReducer.State.Destination.self) { destination in
            switch destination {
            case .licenseList:
                IfLetStore(
                    store.scope(state: \.licenseList, action: \.licenseList),
                    then: { store in
                        LicenseListPage(store: store)
                    }
                )
            }
        }
    }

    func safari(_ viewStore: ViewStoreOf<InfoReducer>) -> some View {
        safari(
            url: viewStore.binding(
                get: \.url,
                send: InfoReducer.Action.url
            ),
            safariView: { url in
                SafariView(url: url)
            }
        )
    }
}

#Preview {
    InfoPage(
        store: Store(
            initialState: InfoReducer.State(version: "v1.0.0")
        ) {
            InfoReducer()
        }
    )
}
