//
//  License.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import Foundation

package struct License: Identifiable, Hashable, Sendable {
  // MARK: - Properties
  package let id: String
  package let name: String
  package let licenseText: String?

  // MARK: - Initialize
  package init(id: String, name: String, licenseText: String?) {
    self.id = id
    self.name = name
    self.licenseText = licenseText
  }
}
