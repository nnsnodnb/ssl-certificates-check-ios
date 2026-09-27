//
//  GoogleBannerView.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/08/27.
//

import Dependencies
import DependenciesInterfaces
import GoogleMobileAds
import SwiftUI

public struct GoogleBannerView: UIViewControllerRepresentable {
  // MARK: - Properties
  public let adUnitID: String
  public let width: CGFloat

  // MARK: - Initialize
  public init(adUnitID: String, width: CGFloat) {
    self.adUnitID = adUnitID
    self.width = width
  }

  // MARK: - UIViewControllerRepresentable
  public func makeUIViewController(context: Context) -> BannerViewController {
    BannerViewController(adUnitID: adUnitID)
  }

  public func updateUIViewController(_ viewController: BannerViewController, context: Context) {
    viewController.setAvailableWidth(width)
  }

  public func sizeThatFits(
    _ proposal: ProposedViewSize,
    uiViewController: BannerViewController,
    context: Context,
  ) -> CGSize? {
    return .init(width: width, height: width)
  }
}
