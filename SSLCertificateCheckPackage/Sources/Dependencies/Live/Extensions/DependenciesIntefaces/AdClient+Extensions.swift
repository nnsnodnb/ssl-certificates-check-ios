//
//  AdClient+Extensions.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/08/27.
//

import DependenciesInterfaces
import GoogleMobileAds
import SwiftUI

public extension AdClient {
  static let google: Self = .init(
    make: { adUnitID, size in
      AnyView(
        GoogleBannerView(adUnitID: adUnitID, size: size)
      )
    },
  )
}
