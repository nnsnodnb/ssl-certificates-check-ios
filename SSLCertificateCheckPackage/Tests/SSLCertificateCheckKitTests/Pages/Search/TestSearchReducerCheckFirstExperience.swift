//
//  TestSearchReducerCheckFirstExperience.swift
//
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
import Foundation
@testable import SSLCertificateCheckKit
import Testing
import X509Parser

@MainActor
struct TestSearchReducerCheckFirstExperience {
  @Test
  func testIsCheckFirstExperienceIsFalse() async throws {
    let store = TestStore(
      initialState: SearchReducer.State(isCheckFirstExperience: false),
      reducer: {
        SearchReducer()
      },
    )

    await store.send(.checkFirstExperience)
  }

  @Test(
    .dependencies {
      $0.keyValueStore.getWasRequestReviewFinishFirstSearchExperience = { false }
      $0.keyValueStore.setWasRequestReviewFinishFirstSearchExperience = { _ in }
    }
  )
  func testIsCheckFirstExperienceIsTrueWasRequestReviewFinishFirstSearchExperienceIsFalse() async throws {
    let store = TestStore(
      initialState: SearchReducer.State(
        searchButtonDisabled: false,
        text: "example.com",
        searchableURL: URL(string: "https://example.com"),
        isCheckFirstExperience: true,
      ),
      reducer: {
        SearchReducer()
      },
    )

    await store.send(.checkFirstExperience) {
      $0.isCheckFirstExperience = false
    }
    await store.receive(\.checkFirstExperienceResponse, .success(false)) {
      $0.isRequestReview = true
    }
  }

  @Test(
    .dependencies {
      $0.keyValueStore.getWasRequestReviewFinishFirstSearchExperience = { true }
      $0.keyValueStore.setWasRequestReviewFinishFirstSearchExperience = { _ in }
    }
  )
  func testIsCheckFirstExperienceIsTrueWasRequestReviewFinishFirstSearchExperienceIsTrue() async throws {
    let store = TestStore(
      initialState: SearchReducer.State(
        searchButtonDisabled: false,
        text: "example.com",
        searchableURL: URL(string: "https://example.com"),
        isCheckFirstExperience: true,
      ),
      reducer: {
        SearchReducer()
      },
    )

    await store.send(.checkFirstExperience) {
      $0.isCheckFirstExperience = false
    }
    await store.receive(\.checkFirstExperienceResponse, .success(true))
  }
}
