//
//  SearchPage.swift
//
//
//  Created by Yuya Oka on 2023/10/13.
//

import ComposableArchitecture
import DependenciesInterfaces
import Logger
import SFSafeSymbols
import StoreKit
import SwiftUI
import X509Parser

@Reducer
public struct SearchReducer: Sendable {
  // MARK: - Path
  @Reducer
  public enum Path {
    case searchResult(SearchResultReducer)
    case searchResultDetail(SearchResultDetailReducer)
  }

  // MARK: - Destination
  @Reducer
  public enum Destination {
    case info(InfoReducer)
    case alert(AlertState<Alert>)

    // MARK: - Alert
    @CasePathable
    public enum Alert: Equatable {
      case watch(URL)
    }
  }

  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    // MARK: - Properties
    var searchButtonDisabled = true
    var text: String = ""
    var isShareExtensionImageShow = false
    var searchPageBottomBannerAdUnitID: String?
    var searchableURL: URL?
    var searchResult: Identified<[X509], SearchResultReducer.State?>?
    var searchResultDetail: Identified<X509, SearchResultDetailReducer.State?>?
    var isCheckFirstExperience = false
    var isRequestReview = false
    var isLoading = false
    //    var destinations: [Destination] = []
    var path: StackState<Path.State> = .init()
    @Presents var destination: Destination.State?
    @Shared(.inMemory("key_premium_subscription_is_active"))
    public var isPremiumActive = false
  }

  // MARK: - Action
  public enum Action {
    case onAppear
    case preloadRewardedAds
    case textChanged(String)
    case pasteURLChanged(URL)
    case universalLinksURLChanged(URL)
    case openInfo
    case showBeforeAdsAlertIfNeeded
    case search(URL)
    case toggleIntroductionShareExtension
    case checkFirstExperience
    case displayedRequestReview
    case searchResponse(Result<[X509], Error>)
    case checkFirstExperienceResponse(Result<Bool, Error>)
    case path(StackActionOf<Path>)
    case destination(PresentationAction<Destination.Action>)

    // MARK: - Error
    @CasePathable
    public enum Error: Swift.Error {
      case search
      case checkFirstExperience
    }
  }

  // MARK: - Properties
  @Dependency(\.adUnitID)
  private var adUnitID
  @Dependency(\.bundle)
  private var bundle
  @Dependency(\.search)
  private var search
  @Dependency(\.keyValueStore)
  private var keyValueStore
  @Dependency(\.rewardedInterstitialAd)
  private var rewardedInterstitialAd

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        guard !state.isPremiumActive else { return .none }
        state.searchPageBottomBannerAdUnitID = try? adUnitID.searchPageBottomBannerAdUnitID()
        return .send(.preloadRewardedAds)
      case .preloadRewardedAds:
        guard !state.isPremiumActive else { return .none }
        return .run(
          priority: .background,
          operation: { _ in
            try await rewardedInterstitialAd.load()
          },
        )
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
        state.path = .init()
        state.destination = nil
        return .send(.textChanged(host))
      case .openInfo:
        let version = bundle.shortVersionString()
        state.destination = .info(.init(version: "v\(version)"))
        Logger.info("Open Info")
        return .none
      case .showBeforeAdsAlertIfNeeded:
        guard !state.searchButtonDisabled,
              let url = state.searchableURL else { return .none }
        if state.isPremiumActive {
          return .send(.search(url))
        }
        state.destination = .alert(
          AlertState(
            title: {
              TextState("You can obtain the certificate data by watching an ad.")
            },
            actions: {
              ButtonState(
                role: .cancel,
                label: {
                  TextState("Cancel")
                },
              )
              ButtonState(
                action: .watch(url),
                label: {
                  TextState("Continue")
                },
              )
            },
          )
        )
        return .none
      case let .search(url):
        guard !state.searchButtonDisabled else {
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
        guard let url = state.searchableURL,
              let host = url.host(percentEncoded: false) else { return .none }
        state.path.append(.searchResult(.init(domain: host, certificates: .init(uniqueElements: certificates))))
        Logger.info("Open SearchResult")
        return .none
      case .searchResponse(.failure):
        state.isLoading = false
        state.destination = .alert(
          AlertState(
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
        )
        return .none
      case let .checkFirstExperienceResponse(.success(result)):
        guard !result else { return .none }
        state.isRequestReview = true
        return .none
      case .checkFirstExperienceResponse(.failure):
        // do not enter
        return .none
      case let .path(.element(id: _, action: .searchResult(.delegate(.goSearchResultDetail(x509))))):
        state.path.append(.searchResultDetail(.init(x509: x509)))
        return .none
      case .path(.element(id: _, action: .searchResultDetail(.appear))):
        state.isCheckFirstExperience = true
        return .none
      case .path:
        return .none
      case let .destination(.presented(.alert(.watch(url)))):
        Logger.info("Start load Ads")
        return .run(
          operation: { send in
            let result = try await rewardedInterstitialAd.show()
            guard result > 0 else {
              await send(.preloadRewardedAds)
              return
            }
            await send(.search(url))
            await send(.preloadRewardedAds)
          },
          catch: { _, send in
            await send(.preloadRewardedAds)
          }
        )
      case .destination:
        return .none
      }
    }
    .forEach(\.path, action: \.path)
    .ifLet(\.$destination, action: \.destination)
  }
}

// MARK: - SearchReducer.Path.State Equatable
extension SearchReducer.Path.State: Equatable {}

// MARK: - SearchReducer.Path.Destination Equatable
extension SearchReducer.Destination.State: Equatable {}

public struct SearchPage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<SearchReducer>

  @FocusState private var isFocused: Bool
  @Environment(\.horizontalSizeClass)
  private var horizontalSizeClass
  @Environment(\.verticalSizeClass)
  private var verticalSizeClass
  @Environment(\.requestReview)
  private var requestReview
  @Dependency(\.adClient)
  private var adClient

  // MARK: - Body
  public var body: some View {
    SheetOrFullScreenCoverWrap(
      content: {
        NavigationStack(
          path: $store.scope(\.path, action: \.path),
          root: {
            form
              .navigationTitle("Check TLS/SSL Certificates")
              .navigationBarTitleDisplayMode(.inline)
              .navigationScrollEdgeEffectSoft()
              .toolbar(
                store: store,
                keyboardClose: {
                  isFocused = false
                },
              )
              .keyboardSafeAreaInset(
                keyboardClose: {
                  isFocused = false
                },
                isFocused: isFocused,
              )
              .onAppear {
                store.send(.checkFirstExperience)
              }
          },
          destination: { store in
            switch store.case {
            case let .searchResult(store):
              SearchResultPage(store: store)
            case let .searchResultDetail(store):
              SearchResultDetailPage(store: store)
            }
          },
        )
      },
      item: $store.scope(\.destination, action: \.destination).info,
      sheet: { store in
        InfoPage(store: store)
      },
    )
    .onAppear {
      store.send(.onAppear)
    }
    .alert(
      $store.scope(\.destination, action: \.destination).alert,
      action: { action in
        if let action {
          store.send(.destination(.presented(.alert(action))))
        }
      }
    )
    .onOpenURL(perform: { url in
      store.send(.universalLinksURLChanged(url))
    })
    .onChange(of: store.isRequestReview, initial: false, { _, newValue in
      guard newValue else { return }
      requestReview()
      store.send(.displayedRequestReview)
    })
  }
}

// MARK: - Private method
private extension SearchPage {
  var form: some View {
    GeometryReader { proxy in
      Form {
        inputSection
        introductionShareExtensionSection(proxy: proxy)
        if !store.isPremiumActive {
          bottomAdBannerSection(proxy: proxy)
        }
      }
      .overlay {
        if store.isLoading {
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

  var inputSection: some View {
    Section(
      content: {
        HStack(alignment: .center, spacing: 0) {
          Text("https://")
            .padding(.horizontal, 8)
          Divider()
          HStack(alignment: .center, spacing: 0) {
            TextField(
              "example.com",
              text: $store.text.sending(\.textChanged)
            )
            .keyboardType(.URL)
            .textCase(.lowercase)
            .focused($isFocused)
            .padding(.horizontal, 8)
            PasteButton(payloadType: URL.self) { urls in
              guard let url = urls.first else { return }
              Task { @MainActor in
                store.send(.pasteURLChanged(url))
              }
            }
            .buttonBorderShape(.capsule)
            .labelStyle(.iconOnly)
            .offset(x: 8)
          }
        }
      },
      header: {
        Text("Enter the host you want to check")
          .padding(.top, 16)
      },
    )
  }

  func introductionShareExtensionSection(proxy: GeometryProxy) -> some View {
    Section {
      VStack(alignment: .leading, spacing: 18) {
        VStack(alignment: .center, spacing: 8) {
          Text("App provides ShareExtension feature")
            .frame(maxWidth: .infinity, alignment: .leading)
          Divider()
          if store.isShareExtensionImageShow {
            VStack(alignment: .center, spacing: 12) {
              Text("Open a https site and open share sheet in Safari. Then tap '**CertsCheck**' logo.")
                .frame(maxWidth: .infinity, alignment: .leading)
              Image(.imgShareExtension)
                .resizable()
                .scaledToFit()
                .modifier {
                  if horizontalSizeClass == .regular && verticalSizeClass == .regular {
                    $0.frame(maxWidth: proxy.frame(in: .global).size.width * 0.3)
                  } else {
                    $0
                  }
                }
                .clipShape(RoundedRectangle(cornerSize: .init(width: 12, height: 12)))
            }
          }
          Button(
            action: {
              store.send(.toggleIntroductionShareExtension)
            },
            label: {
              Text(store.isShareExtensionImageShow ? "Close" : "About more")
                .frame(maxWidth: .infinity)
            }
          )
          .buttonStyle(BorderlessButtonStyle())
          .frame(height: 24)
          .frame(maxWidth: .infinity)
        }
      }
      .padding(.vertical, 8)
    }
  }

  @ViewBuilder
  func bottomAdBannerSection(proxy: GeometryProxy) -> some View {
    if let adUnitID = store.searchPageBottomBannerAdUnitID {
      Section {
        VStack(alignment: .center, spacing: 8) {
          Text("Advertisement")
            .font(.system(size: 14))
          adClient.make(adUnitID: adUnitID, size: .largeBanner)
            .frame(
              width: max(proxy.frame(in: .global).size.width - 20, 0),
              height: max(proxy.frame(in: .global).size.width - 20, 0),
            )
        }
      }
      .listRowBackground(Color.clear)
      .listRowSeparator(.hidden)
    }
  }
}

private extension View {
  func toolbar(store: StoreOf<SearchReducer>, keyboardClose: @escaping () -> Void) -> some View {
    toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button(
          action: {
            store.send(.openInfo)
          },
          label: {
            if #available(iOS 26.0, *) {
              Image(systemSymbol: .info)
            } else {
              Image(systemSymbol: .infoCircle)
            }
          }
        )
      }
      ToolbarItem(placement: .topBarTrailing) {
        Button(
          action: {
            keyboardClose()
            store.send(.showBeforeAdsAlertIfNeeded)
          },
          label: {
            Group {
              if #available(iOS 26.0, *) {
                Image(systemSymbol: .magnifyingglass)
              } else {
                Image(systemSymbol: .magnifyingglassCircle)
              }
            }
            .bold()
            .disabled(store.searchButtonDisabled)
          }
        )
      }
      ToolbarItemGroup(placement: .keyboard) {
        if #unavailable(iOS 26.0) {
          Spacer()
          Button(action: keyboardClose) {
            Text("Close")
              .bold()
          }
        }
      }
    }
  }

  func keyboardSafeAreaInset(keyboardClose: @escaping () -> Void, isFocused: Bool) -> some View {
    safeAreaInset(edge: .bottom) {
      if #available(iOS 26.0, *), isFocused {
        HStack(alignment: .center, spacing: 0) {
          Spacer()
            .frame(maxWidth: .infinity)
          Button(action: keyboardClose) {
            Text("Close")
              .bold()
              .foregroundStyle(Color(.label))
              .padding(12)
              .glassEffect()
          }
        }
        .padding(8)
      }
    }
  }
}

#Preview {
  SearchPage(
    store: .init(
      initialState: SearchReducer.State(),
      reducer: {
        SearchReducer()
      },
    ),
  )
}
