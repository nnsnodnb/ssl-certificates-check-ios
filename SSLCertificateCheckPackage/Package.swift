// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// MARK: - String extension
extension String {
    static let packageName = "SSLCertificateCheckPackage"
}

// MARK: - Target.Dependency extension
extension Target.Dependency {
    static var sslCertificateCheckPackage: Self {
        .target(name: .packageName)
    }

    static var composableArchitecture: Self {
        .product(
            name: "ComposableArchitecture",
            package: "swift-composable-architecture"
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
extension Target.PluginUsage {
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
            targets: [.packageName]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/maiyama18/LicensesPlugin.git", .upToNextMajor(from: "0.1.6")),
        .package(url: "https://github.com/gematik/OpenSSL-Swift.git", .upToNextMajor(from: "4.1.0")),
        .package(url: "https://github.com/realm/SwiftLint.git", .upToNextMajor(from: "0.53.0")),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", .upToNextMajor(from: "1.2.0")),
    ],
    targets: [
        .target(
            name: .packageName,
            dependencies: [
                .composableArchitecture,
                .openSSLSwift,
            ],
            plugins: [
                .licensesPlugin,
                .swiftLintPlugin,
            ]
        ),
        .testTarget(
            name: .packageName + "Tests",
            dependencies: [
                .sslCertificateCheckPackage,
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
