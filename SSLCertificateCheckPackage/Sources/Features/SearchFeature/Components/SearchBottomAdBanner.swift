//
//  SearchBottomAdBanner.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/18.
//

import GoogleMobileAds
import SwiftUI

package struct SearchBottomAdBanner: UIViewRepresentable {
    // MARK: - Properties
    package let adUnitID: String

    package func makeUIView(context: Context) -> BannerView {
        let adSize = AdSizeLargeBanner // AdSizeMediumRectangle
        let banner = BannerView(adSize: adSize)
        banner.adUnitID = adUnitID
        banner.load(Request())
        banner.delegate = context.coordinator
        return banner
    }

    package func updateUIView(_ uiView: BannerView, context: Context) {
    }

    package func makeCoordinator() -> Coordinator {
        .init(parent: self)
    }
}

// MARK: - Coordinator
package extension SearchBottomAdBanner {
    final class Coordinator: NSObject, BannerViewDelegate {
        // MARK: - Properties
        private let parent: SearchBottomAdBanner

        // MARK: - Initialize
        init(parent: SearchBottomAdBanner) {
            self.parent = parent
        }
    }
}

#Preview {
    SearchBottomAdBanner(
        adUnitID: "ca-app-pub-3940256099942544/2435281174",
    )
}
