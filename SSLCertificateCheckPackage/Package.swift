// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.
// swiftlint:disable trailing_comma

import PackageDescription

// MARK: - String extension
extension String {
  static let packageName = "SSLCertificateCheckPackage"
  static let application = "Application"
  static let shareExtension = "Share"
}

// MARK: - Target.Dependency extension
extension PackageDescription.Target.Dependency {
  // MARK: - Aliases
  static let appClip: Self = .target(name: "AppClip")
  static let application: Self = .target(name: "Application")
  static let consentFeature: Self = .target(name: "ConsentFeature")
  static let clientDependencies: Self = .target(name: "ClientDependencies")
  static let infoFeature: Self = .target(name: "InfoFeature")
  static let licenseFeature: Self = .target(name: "LicenseFeature")
  static let logger: Self = .target(name: "Logger")
  static let searchFeature: Self = .target(name: "SearchFeature")
  static let subscriptionFeature: Self = .target(name: "SubscriptionFeature")
  static let share: Self = .target(name: "Share")
  static let uiComponents: Self = .target(name: "UIComponents")
  static let x509Parser: Self = .target(name: "X509Parser")

  static var betterSafariView: Self {
    .product(
      name: "BetterSafariView",
      package: "BetterSafariView"
    )
  }

  static var composableArchitecture: Self {
    .product(
      name: "ComposableArchitecture",
      package: "swift-composable-architecture"
    )
  }

  static var dependencies: Self {
    .product(
      name: "Dependencies",
      package: "swift-dependencies"
    )
  }

  static var dependenciesMacros: Self {
    .product(
      name: "DependenciesMacros",
      package: "swift-dependencies"
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
      package: "firebase-ios-sdk"
    )
  }

  static var firebaseCrashlytics: Self {
    .product(
      name: "FirebaseCrashlytics",
      package: "firebase-ios-sdk"
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
      package: "SFSafeSymbols"
    )
  }

  static var x509: Self {
    .product(
      name: "X509",
      package: "swift-certificates"
    )
  }
}

// MARK: - Target.PluginUsage extension
extension PackageDescription.Target.PluginUsage {
  static var licensesPlugin: Self {
    .plugin(
      name: "LicensesPlugin",
      package: "LicensesPlugin"
    )
  }

  static var swiftLintBuildToolPlugin: Self {
    .plugin(
      name: "SwiftLintBuildToolPlugin",
      package: "SwiftLintPlugins"
    )
  }
}

let package = Package(
  name: .packageName,
  platforms: [
    .iOS(.v18),
  ],
  products: [
    .library(
      name: .packageName,
      targets: [.application]
    ),
    .library(
      name: .shareExtension,
      targets: [.shareExtension]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "12.8.0")),
    .package(url: "https://github.com/maiyama18/LicensesPlugin.git", .upToNextMajor(from: "0.2.0")),
    .package(url: "https://github.com/stleamist/BetterSafariView.git", .upToNextMajor(from: "2.4.2")),
    .package(url: "https://github.com/RevenueCat/purchases-ios-spm.git", .upToNextMajor(from: "5.59.0")),
    .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", .upToNextMajor(from: "7.0.0")),
    .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins.git", .upToNextMajor(from: "0.63.2")),
    .package(url: "https://github.com/apple/swift-certificates.git", .upToNextMajor(from: "1.17.1")),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", .upToNextMajor(from: "1.23.1")),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", .upToNextMajor(from: "1.11.0")),
    .package(url: "https://github.com/gohanlon/swift-memberwise-init-macro.git", .upToNextMajor(from: "0.5.2")),
    .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", .upToNextMajor(from: "12.14.0")),
    .package(url: "https://github.com/googleads/swift-package-manager-google-user-messaging-platform.git", .upToNextMajor(from: "3.1.0")),
  ],
  targets: [
    // Application
    .target(
      name: .application,
      dependencies: [
        .consentFeature,
        .firebaseAnalytics,
        .firebaseCrashlytics,
        .googleMobileAds,
        .memberwiseInit,
        .searchFeature,
        .subscriptionFeature,
      ]
    ),
    // AppExtensions
    .target(
      name: .shareExtension,
      path: "Sources/AppExtensions/Share"
    ),
    // Features
    .target(
      name: "ConsentFeature",
      dependencies: [
        .clientDependencies,
        .composableArchitecture,
        .memberwiseInit,
      ],
      path: "Sources/Features/ConsentFeature",
    ),
    .target(
      name: "InfoFeature",
      dependencies: [
        .betterSafariView,
        .composableArchitecture,
        .dependencies,
        .firebaseAnalytics,
        .licenseFeature,
        .memberwiseInit,
        .subscriptionFeature,
        .uiComponents,
      ],
      path: "Sources/Features/InfoFeature"
    ),
    .target(
      name: "LicenseFeature",
      dependencies: [
        .clientDependencies,
        .composableArchitecture,
        .dependencies,
        .firebaseAnalytics,
        .logger,
        .memberwiseInit,
      ],
      path: "Sources/Features/LicenseFeature",
    ),
    .target(
      name: "SearchFeature",
      dependencies: [
        .clientDependencies,
        .composableArchitecture,
        .dependencies,
        .googleMobileAds,
        .infoFeature,
        .logger,
        .memberwiseInit,
        .sfSafeSymbols,
        .subscriptionFeature,
        .uiComponents,
        .x509Parser,
      ],
      path: "Sources/Features/SearchFeature"
    ),
    .target(
      name: "SubscriptionFeature",
      dependencies: [
        .clientDependencies,
        .composableArchitecture,
        .memberwiseInit,
        .revenueCat,
      ],
      path: "Sources/Features/SubscriptionFeature",
    ),
    // Misc
    .target(
      name: "ClientDependencies",
      dependencies: [
        .composableArchitecture,
        .dependencies,
        .dependenciesMacros,
        .googleMobileAds,
        .googleUserMessagingPlatform,
        .memberwiseInit,
        .revenueCat,
        .revenueCatUI,
        .x509Parser,
      ],
      plugins: [
        .licensesPlugin,
      ]
    ),
    .target(
      name: "Logger",
      dependencies: [
        .composableArchitecture,
      ]
    ),
    .target(
      name: "UIComponents",
      dependencies: [
        .memberwiseInit,
        .sfSafeSymbols,
      ]
    ),
    .target(
      name: "X509Parser",
      dependencies: [
        .memberwiseInit,
        .x509,
      ]
    ),
    // Tests
    .testTarget(
      name: "ApplicationTests",
      dependencies: [
        .application,
        .dependencies,
        .dependenciesTestSupport,
      ],
    ),
    .testTarget(
      name: "ConsentFeatureTests",
      dependencies: [
        .consentFeature,
        .dependencies,
        .dependenciesTestSupport,
      ],
    ),
    .testTarget(
      name: "InfoFeatureTests",
      dependencies: [
        .clientDependencies,
        .dependenciesTestSupport,
        .infoFeature,
      ]
    ),
    .testTarget(
      name: "LicenseFeatureTests",
      dependencies: [
        .clientDependencies,
        .licenseFeature,
      ]
    ),
    .testTarget(
      name: "SearchFeatureTests",
      dependencies: [
        .clientDependencies,
        .dependenciesTestSupport,
        .searchFeature,
      ]
    ),
    .testTarget(
      name: "SubscriptionFeatureTests",
      dependencies: [
        .clientDependencies,
        .dependenciesTestSupport,
        .subscriptionFeature,
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

let debugOtherSwiftFlags = [
  "-Xfrontend", "-warn-long-expression-type-checking=500",
  "-Xfrontend", "-warn-long-function-bodies=500",
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
