// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
// swiftlint:disable trailing_comma

import PackageDescription

// MARK: - String extension
extension String {
    static let packageName = "SSLCertificateCheckPackage"
    static let application = "Application"
    static let appClipExtension = "AppClip"
    static let shareExtension = "Share"
}

// MARK: - Target.Dependency extension
extension PackageDescription.Target.Dependency {
    // MARK: - Aliases
    static let appClip: Self = .target(name: "AppClip")
    static let application: Self = .target(name: "Application")
    static let infoFeature: Self = .target(name: "InfoFeature")
    static let licenseFeature: Self = .target(name: "LicenseFeature")
    static let logger: Self = .target(name: "Logger")
    static let searchFeature: Self = .target(name: "SearchFeature")
    static let share: Self = .target(name: "Share")
    static let uiComponents: Self = .target(name: "UIComponents")
    static let x509Parser: Self = .target(name: "X509Parser")

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
            name: .appClipExtension,
            targets: [.appClipExtension]
        ),
        .library(
            name: .shareExtension,
            targets: [.shareExtension]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "10.20.0")),
        .package(url: "https://github.com/maiyama18/LicensesPlugin.git", .upToNextMajor(from: "0.1.6")),
        .package(url: "https://github.com/vsanthanam/SafariUI.git", .upToNextMajor(from: "3.0.2")),
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", .upToNextMajor(from: "4.1.1")),
        .package(url: "https://github.com/realm/SwiftLint.git", .upToNextMajor(from: "0.54.0")),
        .package(url: "https://github.com/apple/swift-certificates.git", .upToNextMajor(from: "1.2.0")),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", .upToNextMajor(from: "1.7.3")),
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", .upToNextMajor(from: "1.2.1")),
    ],
    targets: [
        // Application
        .target(
            name: .application,
            dependencies: [
                .firebaseAnalytics,
                .firebaseCrashlytics,
                .searchFeature,
            ]
        ),
        // AppExtensions
        .target(
            name: .appClipExtension,
            dependencies: [
                .application,
            ],
            path: "Sources/AppExtensions/AppClip"
        ),
        .target(
            name: .shareExtension,
            path: "Sources/AppExtensions/Share"
        ),
        // Features
        .target(
            name: "InfoFeature",
            dependencies: [
                .composableArchitecture,
                .dependencies,
                .firebaseAnalytics,
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
                .dependencies,
                .firebaseAnalytics,
                .logger,
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
                .dependencies,
                .infoFeature,
                .logger,
                .sfSafeSymbols,
                .uiComponents,
                .x509Parser,
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
        .target(
            name: "X509Parser",
            dependencies: [
                .x509,
            ]
        ),
        // Tests
        .testTarget(
            name: "InfoFeatureTests",
            dependencies: [
                .infoFeature,
            ]
        ),
        .testTarget(
            name: "LicenseFeatureTests",
            dependencies: [
                .licenseFeature,
            ]
        ),
        .testTarget(
            name: "SearchFeatureTests",
            dependencies: [
                .searchFeature,
            ]
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

// swiftlint:enable trailing_comma
