//
//  InfoPage.swift
//  
//
//  Created by Yuya Oka on 2023/10/13.
//

import BetterSafariView
import ComposableArchitecture
import LicenseFeature
import SFSafeSymbols
import SubscriptionFeature
import SwiftUI
import UIComponents

package struct InfoPage: View {
    // MARK: - Properties
    @Bindable private var store: StoreOf<InfoReducer>

    // MARK: - Body
    package var body: some View {
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
        .sheet(item: $store.scope(state: \.paywall, action: \.paywall), content: { store in
            PaywallPage(store: store)
        })
        .alert($store.scope(state: \.alert, action: \.alert))
    }

    // MARK: - Initialize
    package init(store: StoreOf<InfoReducer>) {
        self.store = store
    }
}

// MARK: - Private method
private extension InfoPage {
    var form: some View {
        Form {
            firstSection
            secondSection
            thirdSection
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

    @ViewBuilder var secondSection: some View {
        if !store.isPremiumActive {
            Section {
                buttonRow(
                    action: {
                        store.send(.openPaywall)
                    },
                    image: {
                        Image(systemSymbol: .crownFill)
                            .resizable()
                            .foregroundStyle(.yellow)
                    },
                    title: "Subscribe Premium"
                )
            }
        }
    }

    var thirdSection: some View {
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
                        .foregroundStyle(Color.blue.opacity(0.7))
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

private extension View {
    func toolbar(store: StoreOf<InfoReducer>) -> some View {
        toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if #available(iOS 26.0, *) {
                    Button(role: .cancel) {
                        store.send(.close)
                    }
                } else {
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

    func safari(store: Bindable<StoreOf<InfoReducer>>) -> some View {
        safariView(item: store.url.sending(\.url)) { url in
            SafariView(url: url)
                .dismissButtonStyle(.close)
        }
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
