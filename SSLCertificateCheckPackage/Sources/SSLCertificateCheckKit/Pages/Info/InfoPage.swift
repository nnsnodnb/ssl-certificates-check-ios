//
//  InfoPage.swift
//
//
//  Created by Yuya Oka on 2023/10/13.
//

import BetterSafariView
import ComposableArchitecture
import DependenciesInterfaces
import SFSafeSymbols
import SwiftUI

@Reducer
public struct InfoReducer: Sendable {
  // MARK: - Destination
  @Reducer
  public enum Path {
    case licenseList(LicenseListReducer)
  }

  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    // MARK: - Properties
    public let version: String
    @Presents public var paywall: PaywallReducer.State?
    public var visiblePrivacyOptionsRequirements = false
    public var isLoadingConsentForm = false
    public var path: StackState<Path.State> = .init()
    public var url: URL?
    @Presents public  var alert: AlertState<Action.Alert>?
    @Shared(.inMemory("key_premium_subscription_is_active"))
    public var isPremiumActive = false

    // MARK: - Link
    public enum Link {
      case gitHub
      case xTwitter
      case terms
      case privacyPolicy
      case userdataExternalTransmission

      // MARK: - Properties
      public var url: URL {
        switch self {
        case .gitHub:
          return URL(string: "https://github.com/nnsnodnb/ssl-certificates-check-ios")!
        case .xTwitter:
          return URL(string: "https://x.com/nnsnodnb")!
        case .terms:
          return URL(string: "https://github.com/nnsnodnb/ssl-certificates-check-ios/wiki/Terms")!
        case .privacyPolicy:
          return URL(string: "https://github.com/nnsnodnb/ssl-certificates-check-ios/wiki/Privacy-Policy")!
        case .userdataExternalTransmission:
          return URL(string: "https://nnsnodnb.moe/userdata-external-transmission/?app=moe.nnsnodnb.SSLCertificateCheck")!
        }
      }
    }
  }

  // MARK: - Action
  public enum Action {
    case onAppear
    case close
    case openPaywall
    case buyMeACoffee
    case loadConsentForm
    case loadedConsentForm
    case showPresentPrivacyOptions
    case openAppReview
    case pushLicenseList
    case safari(State.Link?)
    case url(URL?)
    case confirmOpenForeignBrowserAlert(URL)
    case openForeignBrowser(URL)
    case path(StackActionOf<Path>)
    case successGifted
    case failureGifted
    case alert(PresentationAction<Alert>)
    case paywall(PresentationAction<PaywallReducer.Action>)
    case licenseList(PresentationAction<LicenseListReducer.Action>)

    // MARK: - Alert
    public enum Alert: Equatable {
      case openURL(URL)
      case close
    }
  }

  // MARK: - Properties
  @Dependency(\.consentInformation)
  private var consentInformation
  @Dependency(\.dismiss)
  private var dismiss
  @Dependency(\.openURL)
  private var openURL
  @Dependency(\.revenueCat)
  private var revenueCat

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.visiblePrivacyOptionsRequirements = consentInformation.visiblePrivacyOptionsRequirements()
        return state.visiblePrivacyOptionsRequirements ? .send(.loadConsentForm) : .none
      case .close:
        return .run(
          operation: { _ in
            await dismiss()
          },
        )
      case .openPaywall:
        state.paywall = .init()
        return .none
      case .buyMeACoffee:
        return .run(
          operation: { send in
            try await revenueCat.buyMeACoffee()
            await send(.successGifted)
          },
          catch: { error, send in
            guard let error = error as? RevenueCatClient.Error,
                  error != .userCancelled else {
              return
            }
            await send(.failureGifted)
          },
        )
      case .loadConsentForm:
        guard state.visiblePrivacyOptionsRequirements else { return .none }
        state.isLoadingConsentForm = true
        return .run(
          operation: { send in
            try await consentInformation.load()
            await send(.loadedConsentForm)
          },
        )
      case .loadedConsentForm:
        state.isLoadingConsentForm = false
        return .none
      case .showPresentPrivacyOptions:
        guard state.visiblePrivacyOptionsRequirements && !state.isLoadingConsentForm else {
          return .none
        }
        return .run(
          operation: { send in
            try await consentInformation.presentPrivacyOptions()
            await send(.loadConsentForm)
          },
          catch: { _, send in
            await send(.loadConsentForm)
          },
        )
      case .openAppReview:
        let url = URL(string: "https://itunes.apple.com/jp/app/id6469147491?mt=8&action=write-review")!
        return .send(.confirmOpenForeignBrowserAlert(url))
      case .pushLicenseList:
        state.path.append(.licenseList(.init()))
        return .none
      case let .safari(.some(link)):
        state.url = link.url
        return .none
      case .safari(.none), .url(.none):
        state.url = nil
        return .none
      case .url(.some):
        return .none
      case let .confirmOpenForeignBrowserAlert(url):
        state.alert = AlertState(
          title: {
            TextState("Open an external browser.")
          },
          actions: {
            ButtonState(
              role: .cancel,
              label: {
                TextState("Cancel")
              }
            )
            ButtonState(
              action: .openURL(url),
              label: {
                TextState("Open")
              }
            )
          }
        )
        return .none
      case let .openForeignBrowser(url):
        return .run { _ in
          await openURL(url)
        }
      case .path:
        return .none
      case .successGifted:
        state.alert = .init(
          title: {
            TextState("Thank you for the coffee gift!")
          },
          actions: {
            ButtonState(
              action: .close,
              label: {
                TextState("Keep it up!")
              },
            )
          },
          message: {
            TextState("I will continue to do my best in development!")
          },
        )
        return .none
      case .failureGifted:
        state.alert = .init(
          title: {
            TextState("The purchase failed.")
          },
          actions: {
            ButtonState(
              action: .close,
              label: {
                TextState("Close")
              },
            )
          },
          message: {
            TextState("Thank you for your kindness")
          },
        )
        return .none
      case let .alert(.presented(.openURL(url))):
        state.alert = nil
        return .send(.openForeignBrowser(url))
      case .alert:
        state.alert = nil
        return .none
      case .paywall(.dismiss):
        state.paywall = nil
        return .none
      case .paywall:
        return .none
      case .licenseList:
        return .none
      }
    }
    .ifLet(\.$paywall, action: \.paywall) {
      PaywallReducer()
    }
    .forEach(\.path, action: \.path)
  }
}

// MARK: - InfoReducer.Path.State Equatable
extension InfoReducer.Path.State: Equatable {}

public struct InfoPage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<InfoReducer>

  // MARK: - Body
  public var body: some View {
    NavigationStack(
      path: $store.scope(\.path, action: \.path),
      root: {
        form
          .navigationTitle("App Information")
          .navigationScrollEdgeEffectSoft()
          .toolbar(store: store)
          .safari(store: $store)
      },
      destination: { store in
        switch store.case {
        case let .licenseList(store):
          LicenseListPage(store: store)
        }
      },
    )
    .sheet(item: $store.scope(\.$paywall, action: \.paywall)) { store in
      PaywallPage(store: store)
    }
    .alert($store.scope(\.$alert, action: \.alert))
    .onAppear {
      store.send(.onAppear)
    }
  }
}

// MARK: - Private method
private extension InfoPage {
  var form: some View {
    Form {
      firstSection
      secondSection
      thirdSection
      fourthSection
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
    Section {
      if !store.isPremiumActive {
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
      buttonRow(
        action: {
          store.send(.buyMeACoffee)
        },
        image: {
          Image(systemSymbol: .cupAndHeatWavesFill)
            .resizable()
            .foregroundStyle(Color.brown)
        },
        title: "Buy me a coffee",
      )
    }
  }

  var thirdSection: some View {
    Section {
      buttonRow(
        action: {
          store.send(.safari(.terms))
        },
        image: {
          Image(systemSymbol: .textDocumentFill)
            .resizable()
            .scaledToFit()
            .foregroundStyle(Color.gray.opacity(0.5))
        },
        title: "Terms of Use"
      )
      buttonRow(
        action: {
          store.send(.safari(.privacyPolicy))
        },
        image: {
          Image(systemSymbol: .handRaisedFill)
            .resizable()
            .scaledToFit()
        },
        title: "Privacy Policy"
      )
      if store.visiblePrivacyOptionsRequirements {
        buttonRow(
          action: {
            if !store.isLoadingConsentForm {
              store.send(.showPresentPrivacyOptions)
            }
          },
          image: {
            if store.isLoadingConsentForm {
              ProgressView()
                .progressViewStyle(.circular)
            } else {
              Image(systemSymbol: .handRaisedSquareFill)
                .resizable()
                .foregroundStyle(.white, .red.opacity(0.9))
            }
          },
          title: "Privacy Settings",
        )
      }
      buttonRow(
        action: {
          store.send(.safari(.userdataExternalTransmission))
        },
        image: {
          Image(systemSymbol: .network)
            .resizable()
            .scaledToFit()
            .foregroundStyle(Color(UIColor.systemCyan))
        },
        title: "About Userdata external tranmission",
      )
    }
  }

  var fourthSection: some View {
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
            .foregroundStyle(.black.opacity(0.7))
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
    @ViewBuilder image: () -> some View,
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

  func safari(store: Bindable<StoreOf<InfoReducer>>) -> some View {
    safariView(item: store.url.sending(\.url)) { url in
      SafariView(url: url)
        .dismissButtonStyle(.close)
    }
  }
}

#Preview {
  NavigationStack(
    root: {
      InfoPage(
        store: .init(
          initialState: InfoReducer.State(version: "v1.0.0"),
          reducer: {
            InfoReducer()
          },
        )
      )
    },
  )
}
