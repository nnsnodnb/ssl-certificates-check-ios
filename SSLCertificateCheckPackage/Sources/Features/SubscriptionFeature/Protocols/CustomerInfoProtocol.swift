//
//  CustomerInfoProtocol.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/02/23.
//

import Foundation

package protocol CustomerInfoProtocol: Equatable, Sendable {
    var isPremiumActive: Bool { get }
}
