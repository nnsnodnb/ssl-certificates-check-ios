//
//  SHA256Digest+Extensions.swift
//
//
//  Created by Yuya Oka on 2023/10/31.
//

import CryptoKit

extension SHA256Digest {
  func hexadecimalString(separator: String = "") -> String {
    map { String(format: "%0.2x", $0) }.joined(separator: separator)
  }
}
