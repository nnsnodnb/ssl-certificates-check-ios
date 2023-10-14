//
//  InfoReducer.swift
//
//
//  Created by Yuya Oka on 2023/10/13.
//

import ComposableArchitecture
import Foundation
import LicenseFeature

package struct InfoReducer: Reducer {
    // MARK: - State
    package struct State: Equatable {
        // MARK: - Properties
        let version: String
        var licenseList: LicenseListReducer.State?
        var destinations: [Destination]
        var interactiveDismissDisabled = true
        var url: URL?

        // MARK: - Destination
        package enum Destination {
            case licenseList
        }

        // MARK: - Link
        package enum Link {
            case gitHub
            case xTwitter

            // MARK: - Properties
            package var url: URL {
                switch self {
                case .gitHub:
                    return URL(string: "https://github.com/nnsnodnb/ssl-certificates-check-ios")!
                case .xTwitter:
                    return URL(string: "https://x.com/nnsnodnb")!
                }
            }
        }

        // MARK: - Initialize
        package init(version: String, licenseList: LicenseListReducer.State? = nil, destinations: [Destination] = []) {
            self.version = version
            self.licenseList = licenseList
            self.destinations = destinations
        }
    }

    // MARK: - Action
    package enum Action {
        case dismiss
        case pushLicenseList
        case safari(State.Link?)
        case url(URL?)
        case navigationPathChanged([State.Destination])
        case licenseList(LicenseListReducer.Action)
    }

    // MARK: - Initialize
    package init() {
    }

    // MARK: - Body
    package var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .dismiss:
                return .none
            case .pushLicenseList:
                state.licenseList = .init()
                state.destinations.append(.licenseList)
                state.interactiveDismissDisabled = true
                return .none
            case let .safari(.some(link)):
                state.url = link.url
                return .none
            case .safari(.none), .url(.none):
                state.url = nil
                return .none
            case .url(.some):
                return .none
            case let .navigationPathChanged(destinations):
                state.destinations = destinations
                state.interactiveDismissDisabled = !destinations.isEmpty
                return .none
            case .licenseList:
                return .none
            }
        }
        .ifLet(\.licenseList, action: /Action.licenseList) {
            LicenseListReducer()
        }
    }
}
