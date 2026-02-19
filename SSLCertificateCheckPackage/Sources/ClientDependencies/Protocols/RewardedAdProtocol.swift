//
//  RewardedAdProtocol.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/17.
//

import Foundation
import GoogleMobileAds

@MainActor
package protocol RewardedAdProtocol: Equatable, Sendable {
    func canPresent() throws
    func present(delegate: (any FullScreenContentDelegate)?, userDidEarnRewardHandler: @escaping () -> Void)
}
