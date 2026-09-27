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
  // MARK: - DetailDestination
  @Reducer
  public enum DetailDestination {
    case licenseList(LicenseListReducer)
  }

  // MARK: - PresentDestination
  @Reducer
  public enum PresentDestination {
    case paywall(PaywallReducer)
    case alert(AlertState<Alert>)

    // MARK: - Alert
    @CasePathable
    public enum Alert: Equatable {
      case openURL(URL)
      case close
    }
  }

  // MARK: - Path
  @Reducer
  public enum Path {
    case licenseDetail(LicenseDetailReducer)
  }

  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    // MARK: - Properties
    public let version: String
    public var columnVisibility: NavigationSplitViewVisibility = .all
    public var isPortrait = false
    public var visiblePrivacyOptionsRequirements = false
    public var isLoadingConsentForm = false
    public var path: StackState<Path.State> = .init()
    public var url: URL?
    @Presents public var detailDestination: DetailDestination.State?
    @Presents public var presentDestination: PresentDestination.State?
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
    case changedColumnVisibility(NavigationSplitViewVisibility)
    case changedIsPortrait(Bool)
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
    case detailDestination(PresentationAction<DetailDestination.Action>)
    case presentDestination(PresentationAction<PresentDestination.Action>)
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
      case let .changedColumnVisibility(columnVisibility):
        state.columnVisibility = columnVisibility
        return .none
      case let .changedIsPortrait(isPortrait):
        state.isPortrait = isPortrait
        return .none
      case .openPaywall:
        state.presentDestination = .paywall(.init())
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
        if case .licenseList = state.detailDestination {
          state.path = .init()
        } else {
          state.detailDestination = .licenseList(.init())
        }
        state.url = nil
        return .none
      case let .safari(.some(link)):
        state.columnVisibility = .automatic
        state.detailDestination = nil
        state.url = link.url
        return .none
      case .safari, .url:
        state.columnVisibility = .all
        state.url = nil
        return .none
      case let .confirmOpenForeignBrowserAlert(url):
        state.presentDestination = .alert(
          AlertState(
            title: {
              TextState("Open an external browser.")
            },
            actions: {
              ButtonState(
                role: .cancel,
                label: {
                  TextState("Cancel")
                },
              )
              ButtonState(
                action: .openURL(url),
                label: {
                  TextState("Open")
                },
              )
            },
          )
        )
        return .none
      case let .openForeignBrowser(url):
        return .run { _ in
          await openURL(url)
        }
      case .path:
        return .none
      case .successGifted:
        state.presentDestination = .alert(
          AlertState(
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
        )
        return .none
      case .failureGifted:
        state.presentDestination = .alert(
          AlertState(
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
        )
        return .none
      case let .detailDestination(.presented(.licenseList(.delegate(.pushLicenseDetail(license))))):
        state.path.append(.licenseDetail(.init(license: license)))
        return .none
      case .detailDestination:
        return .none
      case let .presentDestination(.presented(.alert(.openURL(url)))):
        return .send(.openForeignBrowser(url))
      case .presentDestination:
        return .none
      }
    }
    .ifLet(\.$detailDestination, action: \.detailDestination)
    .ifLet(\.$presentDestination, action: \.presentDestination)
    .forEach(\.path, action: \.path)
  }
}

// MARK: - InfoReducer.DetailDestination.State Equatable
extension InfoReducer.DetailDestination.State: Equatable {}

// MARK: - InfoReducer.PresentDestination.State Equatable
extension InfoReducer.PresentDestination.State: Equatable {}

// MARK: - InfoReducer.Path.State Equatable
extension InfoReducer.Path.State: Equatable {}

public struct InfoPage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<InfoReducer>

  @Dependency(\.mainQueue)
  private var mainQueue
  @Environment(\.horizontalSizeClass)
  private var horizontalSizeClass
  @Environment(\.verticalSizeClass)
  private var verticalSizeClass

  // MARK: - Body
  public var body: some View {
    NavigationSplitView(
      columnVisibility: $store.columnVisibility.sending(\.changedColumnVisibility),
      sidebar: {
        list
          .navigationTitle("App Information")
          .navigationScrollEdgeEffectSoft()
          .toolbar(store: store)
          .modifier {
            if horizontalSizeClass == .compact || verticalSizeClass == .compact {
              $0.safari(store: $store)
            } else {
              $0
            }
          }
      },
      detail: {
        if let destination = store.scope(\.detailDestination, action: \.detailDestination.presented) {
          NavigationStack(
            path: $store.scope(\.path, action: \.path),
            root: {
              switch destination.case {
              case let .licenseList(store):
                LicenseListPage(store: store)
              }
            },
            destination: { store in
              switch store.case {
              case let .licenseDetail(store):
                LicenseDetailPage(store: store)
              }
            },
          )
        } else if let url = store.url, horizontalSizeClass == .regular && verticalSizeClass == .regular {
          SafariView(url: url)
            .dismissButtonStyle(.close)
        } else {
          DetailNilView()
        }
      },
    )
    .sheet(item: $store.scope(\.presentDestination, action: \.presentDestination).paywall) { store in
      PaywallPage(store: store)
    }
    .alert(
      $store.scope(\.presentDestination, action: \.presentDestination).alert,
      action: { action in
        if let action {
          store.send(.presentDestination(.presented(.alert(action))))
        }
      },
    )
    .onGeometryChange(
      for: Bool.self,
      of: { proxy in
        proxy.size.width < proxy.size.height
      },
      action: { isPortrait in
        store.send(.changedIsPortrait(isPortrait))
        // 開いた状態
        guard horizontalSizeClass == .regular && verticalSizeClass == .regular else {
          return
        }
        if isPortrait && store.detailDestination == nil {
          // 縦持ちで遷移先がない場合は全カラム
          Task {
            try? await mainQueue.sleep(for: .milliseconds(1))
            store.send(.changedColumnVisibility(.all))
          }
        } else if !isPortrait {
          // 横持ちであれば強制的に全カラム
          store.send(.changedColumnVisibility(.all))
        }
      },
    )
    .onAppear {
      store.send(.onAppear)
    }
  }
}

// MARK: - Private method
private extension InfoPage {
  enum SidebarSelection {
    case licenses
  }

  var list: some View {
    List(
      selection: Binding<SidebarSelection?>(
        get: {
          switch store.detailDestination {
          case .licenseList:
            .licenses
          case .none:
            nil
          }
        },
        set: { value in
          switch value {
          case .licenses:
            store.send(.pushLicenseList)
          case .none:
            store.send(.detailDestination(.dismiss))
          }
        },
      ),
      content: {
        firstSection
        secondSection
        thirdSection
        fourthSection
      },
    )
    .listStyle(.insetGrouped)
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
