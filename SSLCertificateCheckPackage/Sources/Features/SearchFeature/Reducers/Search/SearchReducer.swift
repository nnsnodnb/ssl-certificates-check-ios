//
//  SearchReducer.swift
//
//
//  Created by Yuya Oka on 2023/10/13.
//

import CasePaths
import ClientDependencies
import ComposableArchitecture
import Foundation
import InfoFeature
import Logger
import X509Parser

@Reducer
package struct SearchReducer {
    // MARK: - State
    @ObservableState
    package struct State: Equatable {
        // MARK: - Properties
        @Presents var info: InfoReducer.State?
        var searchButtonDisabled = true
        var text: String = ""
        var isShareExtensionImageShow = false
        var searchableURL: URL?
        var searchResult: Identified<[X509], SearchResultReducer.State?>?
        var searchResultDetail: Identified<X509, SearchResultDetailReducer.State?>?
        var isCheckFirstExperience = false
        var isRequestReview = false
        var isLoading = false
        var destinations: [Destination] = []
        @Presents var alert: AlertState<Action.Alert>?

        // MARK: - Destination
        package enum Destination: Hashable {
            case searchResult
            case searchResultDetail
        }

        // MARK: - Initialize
        package init(
            info: InfoReducer.State? = nil,
            searchButtonDisabled: Bool = true,
            text: String = "",
            isShareExtensionImageShow: Bool = false,
            searchableURL: URL? = nil,
            searchResult: Identified<[X509], SearchResultReducer.State?>? = nil,
            searchResultDetail: Identified<X509, SearchResultDetailReducer.State?>? = nil,
            isCheckFirstExperience: Bool = false,
            isRequestReview: Bool = false,
            isLoading: Bool = false,
            destinations: [Destination] = [],
            alert: AlertState<Action.Alert>? = nil
        ) {
            self.info = info
            self.searchButtonDisabled = searchButtonDisabled
            self.text = text
            self.isShareExtensionImageShow = isShareExtensionImageShow
            self.searchableURL = searchableURL
            self.searchResult = searchResult
            self.searchResultDetail = searchResultDetail
            self.isCheckFirstExperience = isCheckFirstExperience
            self.isRequestReview = isRequestReview
            self.isLoading = isLoading
            self.destinations = destinations
            self.alert = alert
        }
    }

    // MARK: - Action
    package enum Action: Equatable {
        case textChanged(String)
        case pasteURLChanged(URL)
        case universalLinksURLChanged(URL)
        case openInfo
        case openAds
        case search(URL)
        case toggleIntroductionShareExtension
        case checkFirstExperience
        case displayedRequestReview
        case searchResponse(Result<[X509], Error>)
        case checkFirstExperienceResponse(Result<Bool, Error>)
        case navigationPathChanged([State.Destination])
        case info(PresentationAction<InfoReducer.Action>)
        case searchResult(SearchResultReducer.Action)
        case searchResultDetail(SearchResultDetailReducer.Action)
        case alert(PresentationAction<Alert>)

        // MARK: - Alert
        package enum Alert: Equatable {
        }

        // MARK: - Error
        @CasePathable
        package enum Error: Swift.Error {
            case search
            case checkFirstExperience
        }
    }

    // MARK: - Properties
    @Dependency(\.bundle)
    private var bundle
    @Dependency(\.search)
    private var search
    @Dependency(\.keyValueStore)
    private var keyValueStore
    @Dependency(\.rewardedAd)
    private var rewardedAd

    // MARK: - Body
    package var body: some ReducerOf<Self> {
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
            case let .pasteURLChanged(url):
                guard url.scheme == "https",
                      let host = url.host() else {
                    return .none
                }
                return .send(.textChanged(host))
            case let .universalLinksURLChanged(url):
                guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
                      let queryItems = urlComponents.queryItems,
                      let encodedURL = queryItems.first(where: { $0.name == "encodedURL" })?.value else {
                    return .none
                }
                Logger.debug("Universal Links set encodedURL: \(encodedURL)")
                guard let data = Data(base64Encoded: encodedURL),
                      let plainURLString = String(data: data, encoding: .utf8) else {
                    return .none
                }
                Logger.debug("Universal Links set plainURL: \(plainURLString)")
                guard let plainURL = URL(string: plainURLString),
                      plainURL.scheme == "https",
                      let host = plainURL.host() else {
                    return .none
                }
                state.info = nil
                state.destinations = []
                return .send(.textChanged(host))
            case .openInfo:
                let version = bundle.shortVersionString()
                state.info = .init(version: "v\(version)")
                Logger.info("Open Info")
                return .none
            case .openAds:
                guard !state.searchButtonDisabled,
                      let url = state.searchableURL else {
                    return .none
                }
                state.isLoading = true
                Logger.info("Start load Ads")
                return .run(
                    operation: { send in
                        let result = try await rewardedAd.show()
                        guard result > 0 else { return }
                        await send(.search(url))
                    },
                    catch: { error, send in
                        await send(.searchResponse(.failure(.search)))
                        Logger.error("Failed fetch Ads: \(error)")
                    }
                )
            case let .search(url):
                Logger.info("Start searching")
                return .run(
                    operation: { send in
                        let x509 = try await search.fetchCertificates(url)
                        await send(.searchResponse(.success(x509)))
                    },
                    catch: { error, send in
                        await send(.searchResponse(.failure(.search)))
                        Logger.error("Failed searching: \(error)")
                    }
                )
            case .toggleIntroductionShareExtension:
                state.isShareExtensionImageShow.toggle()
                return .none
            case .checkFirstExperience:
                guard state.isCheckFirstExperience else {
                    return .none
                }
                state.isCheckFirstExperience = false
                return .run { send in
                    let result = try await keyValueStore.getWasRequestReviewFinishFirstSearchExperience()
                    await send(.checkFirstExperienceResponse(.success(result)))
                }
            case .displayedRequestReview:
                state.isRequestReview = false
                return .run { _ in
                    try await keyValueStore.setWasRequestReviewFinishFirstSearchExperience(true)
                }
            case let .searchResponse(.success(certificates)):
                state.isLoading = false
                state.destinations.append(.searchResult)
                state.searchResult = .init(
                    SearchResultReducer.State(certificates: .init(uniqueElements: certificates)),
                    id: certificates
                )
                Logger.info("Open SearchResult")
                return .none
            case .searchResponse(.failure):
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
                return .none
            case let .checkFirstExperienceResponse(.success(result)):
                guard !result else { return .none }
                state.isRequestReview = true
                return .none
            case .checkFirstExperienceResponse(.failure):
                // do not enter
                return .none
            case let .navigationPathChanged(destinations):
                state.destinations = destinations
                if destinations.isEmpty {
                    state.searchResult = nil
                } else if destinations.endIndex == 1 {
                    state.searchResultDetail = nil
                }
                return .none
            case .info(.dismiss), .info(.presented(.close)):
                state.info = nil
                Logger.info("Dismiss Info")
                return .none
            case .info(.presented):
                return .none
            case let .searchResult(.selectCertificate(x509)):
                guard state.searchResult != nil else {
                    return .none
                }
                state.destinations.append(.searchResultDetail)
                state.searchResultDetail = .init(.init(x509: x509), id: x509)
                return .none
            case .searchResult:
                return .none
            case .searchResultDetail(.appear):
                state.isCheckFirstExperience = true
                return .none
            case .alert:
                state.alert = nil
                return .none
            }
        }
        .ifLet(\.$info, action: \.info) {
            InfoReducer()
        }
        .ifLet(\.searchResult, action: \.searchResult) {
            EmptyReducer()
                .ifLet(\.value, action: \.self) {
                    SearchResultReducer()
                }
        }
        .ifLet(\.searchResultDetail, action: \.searchResultDetail) {
            EmptyReducer()
                .ifLet(\.value, action: \.self) {
                    SearchResultDetailReducer()
                }
        }
    }

    // MARK: - Initialize
    package init() {
    }
}
