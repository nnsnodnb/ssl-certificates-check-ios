//
//  TestInfoReducerConfirmOpenForeignBrowserAlert.swift
//  
//
//  Created by Yuya Oka on 2023/10/22.
//

import ComposableArchitecture
@testable import InfoFeature
import XCTest

@MainActor
final class TestInfoReducerConfirmOpenForeignBrowserAlert: XCTestCase { // swiftlint:disable:this type_name
    func testChangedAlert() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test")
        ) {
            InfoReducer()
        }

        let url = URL(string: "https://example.com")!
        await store.send(.confirmOpenForeignBrowserAlert(url)) {
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
