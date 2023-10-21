// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

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
    static let application: Self = .target(name: "Application")
    static let infoFeature: Self = .target(name: "InfoFeature")
    static let licenseFeature: Self = .target(name: "LicenseFeature")
    static let logger: Self = .target(name: "Logger")
    static let searchFeature: Self = .target(name: "SearchFeature")
    static let share: Self = .target(name: "Share")
    static let uiComponents: Self = .target(name: "UIComponents")

    static var composableArchitecture: Self {
        .product(
            name: "ComposableArchitecture",
            package: "swift-composable-architecture"
        )
    }

    static var firebaseAnalyticsSwift: Self {
        .product(
            name: "FirebaseAnalyticsSwift",
            package: "firebase-ios-sdk"
        )
    }

    static var firebaseCrashlytics: Self {
        .product(
            name: "FirebaseCrashlytics",
            package: "firebase-ios-sdk"
        )
    }

    static var openSSLSwift: Self {
        .product(
            name: "OpenSSL-Swift",
            package: "OpenSSL-Swift"
        )
    }

    static var safariUI: Self {
        .product(
            name: "SafariUI",
            package: "SafariUI"
        )
    }

    static var sfSafeSymbols: Self {
        .product(
            name: "SFSafeSymbols",
            package: "SFSafeSymbols"
        )
    }

    static var quick: Self {
        .product(
            name: "Quick",
            package: "Quick"
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

    static var swiftLintPlugin: Self {
        .plugin(
            name: "SwiftLintPlugin",
            package: "SwiftLint"
        )
    }
}

let package = Package(
    name: .packageName,
    platforms: [
        .iOS(.v16),
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
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "10.16.0")),
        .package(url: "https://github.com/maiyama18/LicensesPlugin.git", .upToNextMajor(from: "0.1.6")),
        .package(url: "https://github.com/gematik/OpenSSL-Swift.git", .upToNextMajor(from: "4.1.0")),
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "7.3.0")),
        .package(url: "https://github.com/vsanthanam/SafariUI.git", .upToNextMajor(from: "3.0.1")),
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", .upToNextMajor(from: "4.1.1")),
        .package(url: "https://github.com/realm/SwiftLint.git", .upToNextMajor(from: "0.53.0")),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", .upToNextMajor(from: "1.2.0")),
    ],
    targets: [
        // Application
        .target(
            name: .application,
            dependencies: [
                .firebaseAnalyticsSwift,
                .firebaseCrashlytics,
                .searchFeature,
            ]
        ),
        // AppExtensions
        .target(
            name: .shareExtension,
            path: "Sources/AppExtensions/Share"
        ),
        // Features
        .target(
            name: "InfoFeature",
            dependencies: [
                .composableArchitecture,
                .firebaseAnalyticsSwift,
                .licenseFeature,
                .safariUI,
                .uiComponents,
            ],
            path: "Sources/Features/InfoFeature"
        ),
        .target(
            name: "LicenseFeature",
            dependencies: [
                .composableArchitecture,
                .firebaseAnalyticsSwift,
            ],
            path: "Sources/Features/LicenseFeature",
            plugins: [
                .licensesPlugin,
            ]
        ),
        .target(
            name: "SearchFeature",
            dependencies: [
                .composableArchitecture,
                .infoFeature,
                .logger,
                .openSSLSwift,
                .sfSafeSymbols,
                .uiComponents,
            ],
            path: "Sources/Features/SearchFeature"
        ),
        // Misc
        .target(
            name: "Logger",
            dependencies: [
                .composableArchitecture,
            ]
        ),
        .target(
            name: "UIComponents",
            dependencies: [
                .sfSafeSymbols,
            ]
        ),
        // Tests
        .testTarget(
            name: "InfoFeatureTests",
            dependencies: [
                .infoFeature,
                .quick,
            ]
        ),
        .testTarget(
            name: "LicenseFeatureTests",
            dependencies: [
                .licenseFeature,
                .quick,
            ]
        ),
        .testTarget(
            name: "SearchFeatureTests",
            dependencies: [
                .searchFeature,
                .quick,
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
    "-strict-concurrency=complete",
    "-enable-actor-data-race-checks",
]

for package in package.targets {
    // swiftSettings
    package.swiftSettings = [
        .unsafeFlags(debugOtherSwiftFlags, .when(configuration: .debug)),
    ]
    // plugins
    if let plugins = package.plugins {
        package.plugins = plugins + [.swiftLintPlugin]
    } else {
        package.plugins = [.swiftLintPlugin]
    }
}
