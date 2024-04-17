//
//  SwiftUIView.swift
//  
//
//  Created by Yuya Oka on 2023/10/13.
//

import ComposableArchitecture
import LicenseFeature
import Perception
import SafariUI
import SFSafeSymbols
import SwiftUI
import UIComponents

@MainActor
package struct InfoPage: View {
    // MARK: - Properties
    @Perception.Bindable private var store: StoreOf<InfoReducer>

    // MARK: - Body
    package var body: some View {
        WithPerceptionTracking {
            NavigationStack(
                path: $store.destinations.sending(\.navigationPathChanged),
                root: {
                    form
                        .navigationTitle("App Information")
                        .navigationDestination(store: store)
                        .toolbar(store: store)
                        .safari(store: $store)
                }
            )
            .interactiveDismissDisabled(store.interactiveDismissDisabled)
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }

    // MARK: - Initialize
    package init(store: StoreOf<InfoReducer>) {
        self.store = store
    }
}

// MARK: - Private method
@MainActor
private extension InfoPage {
    var form: some View {
        Form {
            firstSection
            secondSection
        }
    }

    var firstSection: some View {
        Section {
            buttonRow(
                action: {
                    store.send(.safari(.gitHub))
                },
                image: {
                    Image(.icGithub)
                        .resizable()
                },
                title: "Source code"
            )
            buttonRow(
                action: {
                    store.send(.safari(.xTwitter))
                },
                image: {
                    Image(.icXTwitetr)
                        .resizable()
                },
                title: "Contact developer"
            )
        }
    }

    var secondSection: some View {
        Section {
            buttonRow(
                action: {
                    store.send(.openAppReview)
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
                    store.send(.pushLicenseList)
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
                Text(store.version)
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
    func toolbar(store: StoreOf<InfoReducer>) -> some View {
        toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(
                    action: {
                        store.send(.close)
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
                if let store = store.scope(state: \.licenseList, action: \.licenseList.presented) {
                    LicenseListPage(store: store)
                }
            }
        }
    }

    func safari(store: Perception.Bindable<StoreOf<InfoReducer>>) -> some View {
        safari(url: store.url.sending(\.url))
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
