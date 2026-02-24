//
//  SearchPage.swift
//
//
//  Created by Yuya Oka on 2023/10/13.
//

import ComposableArchitecture
import InfoFeature
import MemberwiseInit
import SFSafeSymbols
import StoreKit
import SwiftUI

@MemberwiseInit(.package)
package struct SearchPage: View {
  // MARK: - Properties
  @Init(.package)
  @Bindable private var store: StoreOf<SearchReducer>

  @FocusState private var isFocused: Bool
  @Environment(\.requestReview)
  private var requestReview

  // MARK: - Body
  package var body: some View {
    NavigationStack(
      path: $store.destinations.sending(\.navigationPathChanged),
      root: {
        form
          .navigationTitle("Check TLS/SSL Certificates")
          .navigationBarTitleDisplayMode(.inline)
          .toolbar(
            store: store,
            keyboardClose: {
              isFocused = false
            }
          )
          .navigationDestination(store: store)
          .onAppear {
            store.send(.checkFirstExperience)
          }
      }
    )
    .onAppear {
      store.send(.onAppear)
    }
    .sheet(
      item: $store.scope(state: \.info, action: \.info),
      content: { store in
        InfoPage(store: store)
      }
    )
    .alert($store.scope(state: \.alert, action: \.alert))
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
        introductionShareExtensionSection
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

  var introductionShareExtensionSection: some View {
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
                .aspectRatio(contentMode: .fit)
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
          SearchBottomAdBanner(adUnitID: adUnitID)
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
            store.send(.openAds)
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
        Spacer()
        Button(action: keyboardClose) {
          Text("Close")
            .bold()
        }
        .padding(.trailing, 8)
      }
    }
  }

  func navigationDestination(store: StoreOf<SearchReducer>) -> some View {
    navigationDestination(
      for: SearchReducer.State.Destination.self,
      destination: { destination in
        switch destination {
        case .searchResult:
          if let store = store.scope(state: \.searchResult?.value, action: \.searchResult) {
            SearchResultPage(store: store)
          }
        case .searchResultDetail:
          if let store = store.scope(state: \.searchResultDetail?.value, action: \.searchResultDetail) {
            SearchResultDetailPage(store: store)
          }
        }
      }
    )
  }
}

struct SearchPage_Previews: PreviewProvider {
  static var previews: some View {
    SearchPage(
      store: Store(
        initialState: SearchReducer.State()
      ) {
        SearchReducer()
      }
    )
  }
}
