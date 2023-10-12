// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// MARK: - String extension
extension String {
    static let packageName = "SSLCertificateCheckPackage"
    static let application = "Application"
}

// MARK: - Target.Dependency extension
extension PackageDescription.Target.Dependency {
    // MARK: - Name
    enum Name: String {
        case application = "Application"
        case homeFeature = "HomeFeature"
        case infoFeature = "InfoFeature"
        case licenseFeature = "LicenseFeature"
    }

    // MARK: - Extension
    static func named(_ name: Name) -> Self {
        return .target(name: name.rawValue)
    }

    // MARK: - Aliases
    static let application: Self = .named(.application)
    static let homeFeature: Self = .named(.homeFeature)
    static let infoFeature: Self = .named(.infoFeature)
    static let licenseFeature: Self = .named(.licenseFeature)

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
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "10.16.0")),
        .package(url: "https://github.com/maiyama18/LicensesPlugin.git", .upToNextMajor(from: "0.1.6")),
        .package(url: "https://github.com/gematik/OpenSSL-Swift.git", .upToNextMajor(from: "4.1.0")),
        .package(url: "https://github.com/realm/SwiftLint.git", .upToNextMajor(from: "0.53.0")),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", .upToNextMajor(from: "1.2.0")),
    ],
    targets: [
        // Application
        .target(
            name: .application,
            dependencies: [
                .homeFeature,
                .firebaseAnalyticsSwift,
                .firebaseCrashlytics,
            ],
            plugins: [
                .swiftLintPlugin,
            ]
        ),
        // Features
        .target(
            name: "HomeFeature",
            dependencies: [
                .composableArchitecture,
            ],
            path: "Sources/Features/HomeFeature",
            plugins: [
                .swiftLintPlugin,
            ]
        ),
        .target(
            name: "InfoFeature",
            dependencies: [
                .composableArchitecture,
                .firebaseAnalyticsSwift,
                .licenseFeature,
            ],
            path: "Sources/Features/InfoFeature",
            plugins: [
                .swiftLintPlugin,
            ]
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
                .swiftLintPlugin,
            ]
        ),
        // Tests
        .testTarget(
            name: "HomeFeatureTests",
            dependencies: [
                .homeFeature,
            ]
        ),
    ]
)

for package in package.targets {
    let debugOtherSwiftFlags = [
        "-Xfrontend", "-warn-long-expression-type-checking=500",
        "-Xfrontend", "-warn-long-function-bodies=500",
        "-strict-concurrency=complete",
        "-enable-actor-data-race-checks",
    ]
    package.swiftSettings = [
        .unsafeFlags(debugOtherSwiftFlags, .when(configuration: .debug)),
    ]
}
