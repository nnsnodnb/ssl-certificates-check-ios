//
//  TestInfoReducer.swift
//  
//
//  Created by Yuya Oka on 2023/10/15.
//

import ComposableArchitecture
@testable import InfoFeature
import XCTest

@MainActor
final class TestInfoReducer: XCTestCase {
    func testDismiss() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test")
        ) {
            InfoReducer()
        }

        await store.send(.dismiss)
    }

    func testOpenAppReview() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test")
        ) {
            InfoReducer()
        }

        await store.send(.openAppReview)
        let url = URL(string: "https://itunes.apple.com/jp/app/id6469147491?mt=8&action=write-review")!
        await store.receive(.confirmOpenForeignBrowserAlert(url), timeout: 0) {
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

    func testPushLicenseList() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test")
        ) {
            InfoReducer()
        }

        await store.send(.pushLicenseList) {
            $0.licenseList = .init()
            $0.destinations = [.licenseList]
            $0.interactiveDismissDisabled = true
        }
    }

    func testSafari() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test")
        ) {
            InfoReducer()
        }

        // gitHub
        await store.send(.safari(.gitHub)) {
            $0.url = URL(string: "https://github.com/nnsnodnb/ssl-certificates-check-ios")!
        }
        // xTwitter
        await store.send(.safari(.xTwitter)) {
            $0.url = URL(string: "https://x.com/nnsnodnb")!
        }
        // none
        await store.send(.safari(nil)) {
            $0.url = nil
        }
    }

    func testURL() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test")
        ) {
            InfoReducer()
        }

        // some
        await store.send(.url(URL(string: "https://github.com/nnsnodnb/ssl-certificates-check-ios")))
        // none
        await store.send(.safari(.gitHub)) {
            $0.url = URL(string: "https://github.com/nnsnodnb/ssl-certificates-check-ios")!
        }
        await store.send(.url(nil)) {
            $0.url = nil
        }
    }

    func testConfirmOpenForeignBrowserAlert() async throws {
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

    func testOpenForeignBrowser() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test")
        ) {
            InfoReducer()
        }

        store.dependencies.application = .init(
            open: { _ in true }
        )

        let url = URL(string: "https://example.com")!
        await store.send(.openForeignBrowser(url))
    }

    func testNavigationPathChanged() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test")
        ) {
            InfoReducer()
        }

        await store.send(.navigationPathChanged([.licenseList])) {
            $0.destinations = [.licenseList]
            $0.interactiveDismissDisabled = true
        }
        await store.send(.navigationPathChanged([])) {
            $0.destinations = []
            $0.interactiveDismissDisabled = false
        }
    }

    func testAlertDismiss() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test")
        ) {
            InfoReducer()
        }

        store.dependencies.application = .init(
            open: { _ in true }
        )

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
        await store.send(.alert(.dismiss)) {
            $0.alert = nil
        }
    }

    func testAlertPresented() async throws {
        let store = TestStore(
            initialState: InfoReducer.State(version: "v1.0.0-test")
        ) {
            InfoReducer()
        }

        store.dependencies.application = .init(
            open: { _ in true }
        )

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
        await store.send(.alert(.presented(.openURL(url)))) {
            $0.alert = nil
        }
        await store.receive(.openForeignBrowser(url), timeout: 0)
    }
}
