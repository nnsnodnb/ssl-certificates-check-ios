//
//  BannerViewController.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/09/27.
//

import GoogleMobileAds
import UIKit

public final class BannerViewController: UIViewController {
  // MARK: - Properties
  private let bannerView = BannerView()
  private let adUnitID: String
  private var currentSide: CGFloat?

  // MARK: - Initialize
  public init(adUnitID: String) {
    self.adUnitID = adUnitID
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("Please use init(adUnitID:)")
  }

  // MARK: - Life Cycle
  override public func viewDidLoad() {
    super.viewDidLoad()

    bannerView.adUnitID = adUnitID
    bannerView.rootViewController = self
    bannerView.delegate = self
    bannerView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(bannerView)

    NSLayoutConstraint.activate([
      bannerView.topAnchor.constraint(equalTo: view.topAnchor),
      bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      bannerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])

    if let currentSide {
      loadBanner(side: currentSide)
    }
  }

  public func setAvailableWidth(_ width: CGFloat) {
    let side = min(floor(width), 250)
    guard side > 0, side != currentSide else { return }

    currentSide = side
    if isViewLoaded {
      loadBanner(side: side)
    }
  }

  private func loadBanner(side: CGFloat) {
//    bannerView.adSize = largeLandscapeAnchoredAdaptiveBanner(width: side)
    bannerView.adSize = AdSize(size: .init(width: side, height: side), flags: 0)
    bannerView.load(Request())
  }
}

// MARK: - BannerViewDelegate
extension BannerViewController: BannerViewDelegate {
  public func bannerViewDidReceiveAd(_ bannerView: BannerView) {
  }
}
