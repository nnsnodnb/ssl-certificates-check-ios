//
//  CustomerInfo+Extensions.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/23.
//

import Foundation
import RevenueCat

// MARK: - CustomerInfoProtocol
extension CustomerInfo: CustomerInfoProtocol {
  public var isPremiumActive: Bool {
    entitlements.all["Premium"]?.isActive == true
  }
}
