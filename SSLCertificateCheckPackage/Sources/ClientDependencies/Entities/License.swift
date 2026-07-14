//
//  License.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct License: Identifiable, Hashable, Sendable {
  // MARK: - Properties
  public let id: String
  public let name: String
  public let licenseText: String?
}
