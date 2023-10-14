//
//  SearchReducer.swift
//
//
//  Created by Yuya Oka on 2023/10/13.
//

import ComposableArchitecture
import Foundation
import InfoFeature
import Logger

package struct SearchReducer: Reducer {
    // MARK: - State
    package struct State: Equatable {
        // MARK: - Properties
        var info: InfoReducer.State?
        var searchButtonDisabled = true
        var text: String = ""
        var searchableURL: URL?
        var isLoading = false
        var destinations: [Destination] = []
        @PresentationState var alert: AlertState<Action.Alert>?

        // MARK: - Destination
        package enum Destination: Hashable {
            case searchResult(X509)
        }

        // MARK: - Initialize
        package init(info: InfoReducer.State? = nil) {
            self.info = info
        }
    }

    // MARK: - Action
    package enum Action: Equatable {
        case textChanged(String)
        case openInfo
        case dismissInfo
        case search
        case searchResponse(TaskResult<X509>)
        case navigationPathChanged([State.Destination])
        case info(InfoReducer.Action)
        case alert(PresentationAction<Alert>)

        // MARK: - Alert
        package enum Alert: Equatable {
        }
    }

    // MARK: - Properties
    @Dependency(\.bundle)
    private var bundle
    @Dependency(\.search)
    private var search

    // MARK: - Body
    package var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .textChanged(text):
                state.text = text
                guard !state.text.isEmpty,
                      let url = URL(string: "https://\(state.text)"),
                      let host = url.host(),
                      !host.isEmpty,
                      host.split(separator: ".").count > 1 else {
                    state.searchButtonDisabled = true
                    state.searchableURL = nil
                    return .none
                }
                state.searchButtonDisabled = false
                state.searchableURL = url
                Logger.info("Valid text: \(text)")
                return .none
            case .openInfo:
                let version = bundle.shortVersionString()
                state.info = .init(version: "v\(version)")
                Logger.info("Open Info")
                return .none
            case .dismissInfo, .info(.dismiss):
                state.info = nil
                Logger.info("Dismiss Info")
                return .none
            case .search:
                guard !state.searchButtonDisabled,
                      let url = state.searchableURL else {
                    return .none
                }
                state.isLoading = true
                Logger.info("Start searching")
                return .run(
                    operation: { send in
                        let x509 = try await search.fetchCertificates(url)
                        await send(.searchResponse(.success(x509)))
                    },
                    catch: { error, send in
                        await send(.searchResponse(.failure(error)))
                    }
                )
            case let .searchResponse(.success(x509)):
                state.isLoading = false
                state.destinations.append(.searchResult(x509))
                Logger.info("Open SearchResult")
                return .none
            case let .searchResponse(.failure(error)):
                state.isLoading = false
                state.alert = AlertState(
                    title: {
                        TextState("Failed to obtain certificate")
                    },
                    actions: {
                        ButtonState(
                            label: {
                                TextState("Close")
                            }
                        )
                    },
                    message: {
                        TextState("Please check or re-run the URL.")
                    }
                )
                Logger.error("Failed searching: \(error)")
                return .none
            case let .navigationPathChanged(destinations):
                state.destinations = destinations
                return .none
            case .info:
                return .none
            case .alert:
                state.alert = nil
                return .none
            }
        }
        .ifLet(\.info, action: /Action.info) {
            InfoReducer()
        }
    }
}
