//
//  IdentifiedArrayOf+Extensions.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/10/25.
//

import Foundation
import IdentifiedCollections

extension IdentifiedArrayOf where Element: Identifiable {
  subscript (safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}
