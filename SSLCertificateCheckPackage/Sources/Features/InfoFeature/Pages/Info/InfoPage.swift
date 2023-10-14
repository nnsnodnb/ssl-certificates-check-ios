//
//  SwiftUIView.swift
//  
//
//  Created by Yuya Oka on 2023/10/13.
//

import ComposableArchitecture
import LicenseFeature
import SFSafeSymbols
import SwiftUI
import UIComponents

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
                }
            )
        })
    }

    // MARK: - Initialize
    package init(store: StoreOf<InfoReducer>) {
        self.store = store
    }
}

// MARK: - Private method
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
                    print("GitHub")
                },
                image: {
                    Image(.icGithub)
                        .resizable()
                },
                title: "Source codes"
            )
            buttonRow(
                action: {
                    print("Twitter")
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
                    print("Review")
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
                Text("v1.0.0") // TODO: Version
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
                    store.scope(state: \.licenseList, action: InfoReducer.Action.licenseList),
                    then: { store in
                        LicenseListPage(store: store)
                    }
                )
            }
        }
    }
}

#Preview {
    InfoPage(
        store: Store(
            initialState: InfoReducer.State()
        ) {
            InfoReducer()
        }
    )
}
