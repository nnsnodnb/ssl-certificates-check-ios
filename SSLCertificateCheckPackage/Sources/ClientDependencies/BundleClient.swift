//
//  BundleClient.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct BundleClient: Sendable {
  // MARK: - Properties
  public var shortVersionString: @Sendable () -> String = { "" }
}

// MARK: - DependencyKey
extension BundleClient: DependencyKey {
  public static let liveValue: BundleClient = .init(
    shortVersionString: {
      Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }
  )
  public static let testValue: BundleClient = .init()
}

// MARK: - DependencyValues
public extension DependencyValues {
  var bundle: BundleClient {
    get {
      self[BundleClient.self]
    }
    set {
      self[BundleClient.self] = newValue
    }
  }
}
