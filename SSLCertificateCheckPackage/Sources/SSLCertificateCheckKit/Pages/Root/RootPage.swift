//
//  RootPage.swift
//
//
//  Created by Yuya Oka on 2023/10/12.
//

import ComposableArchitecture
import Dependencies
import DependenciesInterfaces
import IssueReporting
import MemberwiseInit
import SwiftUI

@Reducer
@MemberwiseInit(.public)
public struct RootReducer: Sendable {
  // MARK: - Destination
  @Reducer
  public enum Destination {
    case checkSubscription(CheckSubscriptionReducer)
    case consent(ConsentReducer)
    case main(MainReducer)
  }

  // MARK: - State
  @ObservableState
  @MemberwiseInit(.public)
  public struct State: Equatable {
    @Init(.public, default: nil)
    @Presents public var destination: Destination.State?
  }

  // MARK: - Action
  public enum Action {
    case showCheckSubscription
    case showConsent
    case destination(PresentationAction<Destination.Action>)
  }

  // MARK: - Dependency
  @Dependency(\.bundle)
  private var bundle

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .showCheckSubscription:
        state.destination = .checkSubscription(.init())
        return .none
      case .showConsent:
        state.destination = .consent(.init())
        return .none
      case .destination(.presented(.checkSubscription(.delegate(.completed)))):
        return .send(.showConsent)
      case .destination(.presented(.consent(.delegate(.completedConsent)))):
        let version = bundle.shortVersionString()
        state.destination = .main(.init(version: "v\(version)"))
        return .none
      case .destination:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination)
  }
}

@MemberwiseInit(.public)
public struct RootPage: View {
  // MARK: - Properties
  @Init(.public)
  public let store: StoreOf<RootReducer>

  // MARK: - Dependencies
  @Dependency(\.consentInformation)
  private var consentInformation

  // MARK: - Body
  public var body: some View {
    if isTesting {
      Text("Run Testing")
    } else if let store = store.scope(\.destination, action: \.destination.presented) {
      switch store.case {
      case let .checkSubscription(store):
        CheckSubscriptionPage(store: store)
      case let .consent(store):
        ConsentPage(store: store)
      case let .main(store):
        MainPage(store: store)
      }
    } else {
      initializeView
    }
  }

  private var initializeView: some View {
    Color(.systemBackground)
      .overlay {
        ProgressView()
          .progressViewStyle(.circular)
      }
      .task {
        store.send(.showCheckSubscription)
      }
  }
}

// MARK: - RootReducer.Destination.State Equatable
extension RootReducer.Destination.State: Equatable {}

struct RootPage_Previews: PreviewProvider {
  static var previews: some View {
    RootPage(
      store: .init(
        initialState: RootReducer.State(),
        reducer: {
          RootReducer()
        },
        withDependencies: {
          $0.adUnitID.requestStartRewardAdUnitID = { "ca-app-pub-3940256099942544/6978759866" }
          $0.adUnitID.searchPageBottomBannerAdUnitID = { "ca-app-pub-3940256099942544/2435281174" }
        },
      ),
    )
  }
}
