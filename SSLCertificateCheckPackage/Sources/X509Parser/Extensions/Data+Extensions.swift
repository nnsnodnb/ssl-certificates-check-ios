//
//  Data+Extensions.swift
//
//
//  Created by Yuya Oka on 2023/10/31.
//

import Foundation

extension Data {
    func hexadecimalString(separator: String = "") -> String {
        map { String(format: "%0.2x", $0) }.joined(separator: separator)
    }
}
