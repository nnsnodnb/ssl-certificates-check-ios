// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
// swiftlint:disable trailing_comma

import PackageDescription

let package = Package(
  name: "SSLCertificateCheckPackage",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v18),
  ],
  products: [
    .library(
      name: "SSLCertificateCheckPackage",
      targets: [
        "SSLCertificateCheckKit",
      ],
    ),
    .library(
      name: "DependenciesLive",
      targets: [
        "DependenciesLive",
      ],
    ),
    .library(
      name: "Share",
      targets: [
        "Share",
      ],
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "12.18.0")),
    .package(url: "https://github.com/maiyama18/LicensesPlugin.git", .upToNextMajor(from: "0.2.0")),
    .package(url: "https://github.com/stleamist/BetterSafariView.git", .upToNextMajor(from: "2.4.2")),
    .package(url: "https://github.com/RevenueCat/purchases-ios-spm.git", .upToNextMajor(from: "5.87.1")),
    .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", .upToNextMajor(from: "7.0.0")),
    .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins.git", .upToNextMajor(from: "0.65.1")),
    .package(url: "https://github.com/apple/swift-certificates.git", .upToNextMajor(from: "1.19.4")),
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture.git",
      .upToNextMajor(from: "1.26.2"),
      traits: [
        "ComposableArchitecture2Deprecations",
        // "ComposableArchitecture2DeprecationOverloads",
      ],
    ),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", .upToNextMajor(from: "1.17.1")),
    .package(url: "https://github.com/gohanlon/swift-memberwise-init-macro.git", .upToNextMajor(from: "0.6.0")),
    .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", .upToNextMajor(from: "13.9.0")),
    .package(url: "https://github.com/googleads/swift-package-manager-google-user-messaging-platform.git", .upToNextMajor(from: "3.1.0")),
  ],
  targets: [
    // Application
    .target(
      name: "SSLCertificateCheckKit",
      dependencies: [
        .betterSafariView,
        .composableArchitecture,
        .dependencies,
        .dependenciesInterfaces,
        .firebaseCrashlytics,
        .logger,
        .memberwiseInit,
        .revenueCatUI,
        .sfSafeSymbols,
      ],
    ),
    // AppExtensions
    .target(
      name: "Share",
      path: "Sources/AppExtensions/Share",
    ),
    // Misc
    .target(
      name: "DependenciesInterfaces",
      dependencies: [
        .dependencies,
        .dependenciesMacros,
        .x509Parser,
      ],
      path: "Sources/Dependencies/Interfaces",
      plugins: [
        .licensesPlugin,
      ],
    ),
    .target(
      name: "DependenciesLive",
      dependencies: [
        .dependencies,
        .dependenciesInterfaces,
        .firebaseAnalytics,
        .googleMobileAds,
        .googleUserMessagingPlatform,
        .revenueCat,
      ],
      path: "Sources/Dependencies/Live",
    ),
    .target(
      name: "Logger",
      dependencies: [
        .composableArchitecture,
      ],
    ),
    .target(
      name: "X509Parser",
      dependencies: [
        .memberwiseInit,
        .x509,
      ],
    ),
    // Tests
    .testTarget(
      name: "SSLCertificateCheckKitTests",
      dependencies: [
        .dependenciesInterfaces,
        .dependencies,
        .dependenciesTestSupport,
        .sslCertificateCheckKit,
      ],
    ),
    .testTarget(
      name: "X509ParserTests",
      dependencies: [
        .x509Parser,
      ],
      resources: [
        .process("Resources/"),
      ]
    ),
  ]
)

// MARK: - Target.Dependency
extension PackageDescription.Target.Dependency {
  // MARK: - Aliases
  static let sslCertificateCheckKit: Self = .target(name: "SSLCertificateCheckKit")
  static let clientDependencies: Self = .target(name: "ClientDependencies")
  static let logger: Self = .target(name: "Logger")
  static let share: Self = .target(name: "Share")
  static let x509Parser: Self = .target(name: "X509Parser")

  static var betterSafariView: Self {
    .product(
      name: "BetterSafariView",
      package: "BetterSafariView",
    )
  }

  static var composableArchitecture: Self {
    .product(
      name: "ComposableArchitecture",
      package: "swift-composable-architecture",
    )
  }

  static var dependencies: Self {
    .product(
      name: "Dependencies",
      package: "swift-dependencies",
    )
  }

  static var dependenciesInterfaces: Self {
    .target(name: "DependenciesInterfaces")
  }

  static var dependenciesMacros: Self {
    .product(
      name: "DependenciesMacros",
      package: "swift-dependencies",
    )
  }

  static var dependenciesTestSupport: Self {
    .product(
      name: "DependenciesTestSupport",
      package: "swift-dependencies",
    )
  }

  static var firebaseAnalytics: Self {
    .product(
      name: "FirebaseAnalytics",
      package: "firebase-ios-sdk",
    )
  }

  static var firebaseCrashlytics: Self {
    .product(
      name: "FirebaseCrashlytics",
      package: "firebase-ios-sdk",
    )
  }

  static var googleMobileAds: Self {
    .product(
      name: "GoogleMobileAds",
      package: "swift-package-manager-google-mobile-ads",
    )
  }

  static var googleUserMessagingPlatform: Self {
    .product(
      name: "GoogleUserMessagingPlatform",
      package: "swift-package-manager-google-user-messaging-platform",
    )
  }

  static var memberwiseInit: Self {
    .product(
      name: "MemberwiseInit",
      package: "swift-memberwise-init-macro",
    )
  }

  static var revenueCat: Self {
    .product(
      name: "RevenueCat",
      package: "purchases-ios-spm",
    )
  }

  static var revenueCatUI: Self {
    .product(
      name: "RevenueCatUI",
      package: "purchases-ios-spm",
    )
  }

  static var sfSafeSymbols: Self {
    .product(
      name: "SFSafeSymbols",
      package: "SFSafeSymbols",
    )
  }

  static var x509: Self {
    .product(
      name: "X509",
      package: "swift-certificates",
    )
  }
}

// MARK: - Target.PluginUsage
extension PackageDescription.Target.PluginUsage {
  static var licensesPlugin: Self {
    .plugin(
      name: "LicensesPlugin",
      package: "LicensesPlugin",
    )
  }

  static var swiftLintBuildToolPlugin: Self {
    .plugin(
      name: "SwiftLintBuildToolPlugin",
      package: "SwiftLintPlugins",
    )
  }
}

let debugOtherSwiftFlags = [
  "-Xfrontend", "-warn-long-expression-type-checking=500",
  "-Xfrontend", "-warn-long-function-bodies=500",
  "-strict-concurrency=complete",
  "-enable-actor-data-race-checks",
]

for target in package.targets {
  // swiftSettings
  target.swiftSettings = [
    .unsafeFlags(debugOtherSwiftFlags, .when(configuration: .debug)),
  ]
  // plugins
  if let plugins = target.plugins {
    target.plugins = plugins + [.swiftLintBuildToolPlugin]
  } else {
    target.plugins = [.swiftLintBuildToolPlugin]
  }
}

// swiftlint:enable trailing_comma
