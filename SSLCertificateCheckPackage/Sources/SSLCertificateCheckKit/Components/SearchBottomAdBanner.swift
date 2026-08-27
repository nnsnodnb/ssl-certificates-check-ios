//
//  SearchBottomAdBanner.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/18.
//

import GoogleMobileAds
import MemberwiseInit
import SwiftUI

public struct SearchBottomAdBanner: UIViewRepresentable {
  // MARK: - Properties
  public let adUnitID: String

  public func makeUIView(context: Context) -> BannerView {
    let adSize = AdSizeLargeBanner // AdSizeMediumRectangle
    let banner = BannerView(adSize: adSize)
    banner.adUnitID = adUnitID
    banner.load(Request())
    banner.delegate = context.coordinator
    return banner
  }

  public func updateUIView(_ uiView: BannerView, context: Context) {
  }

  public func makeCoordinator() -> Coordinator {
    .init(parent: self)
  }
}

// MARK: - Coordinator
public extension SearchBottomAdBanner {
  @MemberwiseInit(.public)
  final class Coordinator: NSObject, BannerViewDelegate {
    // MARK: - Properties
    @Init(.public)
    private let parent: SearchBottomAdBanner
  }
}

#Preview {
  SearchBottomAdBanner(
    adUnitID: "ca-app-pub-3940256099942544/2435281174",
  )
}
