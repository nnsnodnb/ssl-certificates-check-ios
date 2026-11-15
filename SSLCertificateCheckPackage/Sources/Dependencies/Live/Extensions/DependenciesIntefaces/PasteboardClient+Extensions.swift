//
//  PasteboardClient+Extensions.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/11/15.
//

import DependenciesInterfaces
import Foundation
import UIKit

public extension PasteboardClient {
  static let uiKit: Self = .init(
    setString: { @MainActor string in
      UIPasteboard.general.string = string
    },
  )
}
