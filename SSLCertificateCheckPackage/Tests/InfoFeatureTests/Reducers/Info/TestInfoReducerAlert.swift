//
//  TestInfoReducerAlert.swift
//
//
//  Created by Yuya Oka on 2023/10/15.
//

import ComposableArchitecture
@testable import InfoFeature
import XCTest

final class TestInfoReducerAlert: XCTestCase {
    // MARK: - Properties
    private var application: ApplicationClient!

    override func setUp() {
        super.setUp()
        application = .init(
            open: { _ in true }
        )
    }

    override func tearDown() {
        super.tearDown()
        application = nil
    }

    @MainActor
    func testAlertDismiss() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(
                version: "v1.0.0-test",
                alert: AlertState(
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
                            action: .openURL(URL(string: "https://example.com")!),
                            label: {
                                TextState("Open")
                            }
                        )
                    }
                )
            )
        ) {
            InfoReducer()
                .dependency(application)
        }

        await store.send(.alert(.dismiss)) {
            $0.alert = nil
        }
    }

    @MainActor
    func testAlertPresented() async throws {
        let url = URL(string: "https://example.com")!
        let store = TestStore(
            initialState: InfoReducer.State(
                version: "v1.0.0-test",
                url: url,
                alert: AlertState(
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
            )
        ) {
            InfoReducer()
                .dependency(application)
        }

        await store.send(.alert(.presented(.openURL(url)))) {
            $0.alert = nil
        }
        await store.receive(\.openForeignBrowser, url, timeout: 0)
    }
}
