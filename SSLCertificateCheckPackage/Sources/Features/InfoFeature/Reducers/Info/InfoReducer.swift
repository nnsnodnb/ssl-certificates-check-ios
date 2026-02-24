//
//  InfoReducer.swift
//
//
//  Created by Yuya Oka on 2023/10/13.
//

import ClientDependencies
import ComposableArchitecture
import Foundation
import LicenseFeature
import MemberwiseInit
import SubscriptionFeature

@Reducer
@MemberwiseInit(.package)
package struct InfoReducer {
  // MARK: - State
  @ObservableState
  package struct State: Equatable {
    // MARK: - Properties
    package let version: String
    @Presents package var paywall: PaywallReducer.State?
    @Presents package var licenseList: LicenseListReducer.State?
    package var destinations: [Destination] = []
    package var interactiveDismissDisabled = false
    package var url: URL?
    @Presents package  var alert: AlertState<Action.Alert>?
    @Shared(.inMemory("key_premium_subscription_is_active"))
    package var isPremiumActive = false

    // MARK: - Destination
    package enum Destination {
      case licenseList
    }

    // MARK: - Link
    package enum Link {
      case gitHub
      case xTwitter
      case terms
      case privacyPolicy

      // MARK: - Properties
      package var url: URL {
        switch self {
        case .gitHub:
          return URL(string: "https://github.com/nnsnodnb/ssl-certificates-check-ios")!
        case .xTwitter:
          return URL(string: "https://x.com/nnsnodnb")!
        case .terms:
          return URL(string: "https://github.com/nnsnodnb/ssl-certificates-check-ios/wiki/Terms")!
        case .privacyPolicy:
          return URL(string: "https://github.com/nnsnodnb/ssl-certificates-check-ios/wiki/Privacy-Policy")!
        }
      }
    }

    // MARK: - Initialize
    package init(
      version: String,
      paywall: PaywallReducer.State? = nil,
      licenseList: LicenseListReducer.State? = nil,
      destinations: [Destination] = [],
      interactiveDismissDisabled: Bool = false,
      url: URL? = nil,
      alert: AlertState<Action.Alert>? = nil
    ) {
      self.version = version
      self.paywall = paywall
      self.licenseList = licenseList
      self.destinations = destinations
      self.interactiveDismissDisabled = interactiveDismissDisabled
      self.url = url
      self.alert = alert
    }
  }

  // MARK: - Action
  package enum Action {
    case close
    case openPaywall
    case buyMeACoffee
    case openAppReview
    case pushLicenseList
    case safari(State.Link?)
    case url(URL?)
    case confirmOpenForeignBrowserAlert(URL)
    case openForeignBrowser(URL)
    case navigationPathChanged([State.Destination])
    case successGifted
    case failureGifted
    case alert(PresentationAction<Alert>)
    case paywall(PresentationAction<PaywallReducer.Action>)
    case licenseList(PresentationAction<LicenseListReducer.Action>)

    // MARK: - Alert
    package enum Alert: Equatable {
      case openURL(URL)
      case close
    }
  }

  // MARK: - Properties
  @Dependency(\.application)
  private var application
  @Dependency(\.revenueCat)
  private var revenueCat

  // MARK: - Body
  package var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .close:
        return .none
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
      case .openAppReview:
        let url = URL(string: "https://itunes.apple.com/jp/app/id6469147491?mt=8&action=write-review")!
        return .send(.confirmOpenForeignBrowserAlert(url))
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
          _ = try await application.open(url)
        }
      case let .navigationPathChanged(destinations):
        state.destinations = destinations
        state.interactiveDismissDisabled = !destinations.isEmpty
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
    .ifLet(\.$licenseList, action: \.licenseList) {
      LicenseListReducer()
    }
  }
}
