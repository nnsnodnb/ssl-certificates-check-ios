//
//  SwiftUIView.swift
//  
//
//  Created by Yuya Oka on 2023/10/13.
//

import ComposableArchitecture
import SFSafeSymbols
import SwiftUI

package struct InfoPage: View {
    // MARK: - Properties
    package let store: StoreOf<InfoReducer>

    // MARK: - Body
    package var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            NavigationStack {
                form()
                    .navigationTitle("App Information")
                    .toolbar {
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
        })
    }

    // MARK: - Initialize
    package init(store: StoreOf<InfoReducer>) {
        self.store = store
    }
}

// MARK: - Private method
private extension InfoPage {
    func form() -> some View {
        Form {
            firstSection()
            secondSection()
        }
    }

    func firstSection() -> some View {
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

    func secondSection() -> some View {
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
                    Image(systemSymbol: .chevronRight)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                        .opacity(0.5)
                }
            }
        )
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
