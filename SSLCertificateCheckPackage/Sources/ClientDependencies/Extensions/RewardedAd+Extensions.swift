//
//  RewardedAd+Extensions.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/17.
//

import Foundation
import GoogleMobileAds

// MARK: - RewardedAdProtocol
@MainActor
extension RewardedAd: RewardedAdProtocol {
    package func canPresent() throws {
        try canPresent(from: nil)
    }

    package func present(delegate: (any FullScreenContentDelegate)?) {
        fullScreenContentDelegate = delegate
        present(from: nil) {
        }
    }
}
