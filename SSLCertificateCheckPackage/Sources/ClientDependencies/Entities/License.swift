//
//  License.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import Foundation
import MemberwiseInit

@MemberwiseInit(.package)
package struct License: Identifiable, Hashable, Sendable {
  // MARK: - Properties
  package let id: String
  package let name: String
  package let licenseText: String?
}
