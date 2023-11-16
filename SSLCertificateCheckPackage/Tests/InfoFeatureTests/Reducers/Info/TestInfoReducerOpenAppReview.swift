//
//  TestInfoReducerOpenAppReview.swift
//
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
import Foundation
@testable import InfoFeature
import XCTest

@MainActor
final class TestInfoReducerOpenAppReview: XCTestCase {
    func testReceiveConfirmOpenForeignBrowserAlert() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test")
        ) {
            InfoReducer()
        }

        await store.send(.openAppReview)
        let url = URL(string: "https://itunes.apple.com/jp/app/id6469147491?mt=8&action=write-review")!
        await store.receive(\.confirmOpenForeignBrowserAlert, timeout: 0) {
            $0.alert = AlertState(
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
        }
    }
}
