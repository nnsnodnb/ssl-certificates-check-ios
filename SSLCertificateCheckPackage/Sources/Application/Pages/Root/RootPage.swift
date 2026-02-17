//
//  RootPage.swift
//
//
//  Created by Yuya Oka on 2023/10/12.
//

import Dependencies
import GoogleMobileAds
import SearchFeature
import SwiftUI
import XCTestDynamicOverlay

public struct RootDependency: Sendable {
    // MARK: - Properties
    public let requestStartRewardAdUnitID: String

    // MARK: - Initialize
    public init(requestStartRewardAdUnitID: String) {
        self.requestStartRewardAdUnitID = requestStartRewardAdUnitID
    }
}

public struct RootPage: View {
    // MARK: - Properties
    public let rootDependency: RootDependency

    // MARK: - Body
    public var body: some View {
        if _XCTIsTesting {
            Text("Run Testing")
        } else {
            // Override adUnitID dependency in here, because this page doesn't have store.
            withDependencies {
                $0.adUnitID = .init(
                    requestStartRewardAdUnitID: { rootDependency.requestStartRewardAdUnitID },
                )
            } operation: {
                SearchPage()
            }
        }
    }

    // MARK: - Initialize
    public init(rootDependency: RootDependency) {
        self.rootDependency = rootDependency
    }
}

#Preview {
    RootPage(
        rootDependency: .init(
            requestStartRewardAdUnitID: "ca-app-pub-3940256099942544/1712485313",
        )
    )
}
