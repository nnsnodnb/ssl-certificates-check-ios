//
//  AdUnitIDClient+Extensions.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/08/27.
//

import DependenciesInterfaces
import Foundation

public extension AdUnitIDClient {
  static let develop: Self = .init(
    requestStartRewardAdUnitID: {
      "ca-app-pub-3940256099942544/6978759866"
    },
    searchPageBottomBannerAdUnitID: {
      "ca-app-pub-3940256099942544/2435281174"
    },
  )
  static let production: Self = .init(
    requestStartRewardAdUnitID: {
      "ca-app-pub-3417597686353524/3610026498"
    },
    searchPageBottomBannerAdUnitID: {
      "ca-app-pub-3417597686353524/1523645555"
    },
  )
}
