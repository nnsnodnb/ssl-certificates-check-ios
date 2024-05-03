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

// MARK: - SwiftSetting extension
extension PackageDescription.SwiftSetting {
    /// Forward-scan matching for trailing closures
    /// - Version: Swift 5.3
    /// - Since: SwiftPM 5.8
    /// - SeeAlso: [SE-0286: Forward-scan matching for trailing closures](https://github.com/apple/swift-evolution/blob/main/proposals/0286-forward-scan-trailing-closures.md)
    static let forwardTrailingClosures: Self = .enableUpcomingFeature("ForwardTrailingClosures")
    /// Introduce existential `any`
    /// - Version: Swift 5.6
    /// - Since: SwiftPM 5.8
    /// - SeeAlso: [SE-0335: Introduce existential `any`](https://github.com/apple/swift-evolution/blob/main/proposals/0335-existential-any.md)
    static let existentialAny: Self = .enableUpcomingFeature("ExistentialAny")
    /// Regex Literals
    /// - Version: Swift 5.7
    /// - Since: SwiftPM 5.8
    /// - SeeAlso: [SE-0354: Regex Literals](https://github.com/apple/swift-evolution/blob/main/proposals/0354-regex-literals.md)
    static let bareSlashRegexLiterals: Self = .enableUpcomingFeature("BareSlashRegexLiterals")
    /// Concise magic file names
    /// - Version: Swift 5.8
    /// - Since: SwiftPM 5.8
    /// - SeeAlso: [SE-0274: Concise magic file names](https://github.com/apple/swift-evolution/blob/main/proposals/0274-magic-file.md)
    static let conciseMagicFile: Self = .enableUpcomingFeature("ConciseMagicFile")
    /// Importing Forward Declared Objective-C Interfaces and Protocols
    /// - Version: Swift 5.9
    /// - Since: SwiftPM 5.9
    /// - SeeAlso: [SE-0384: Importing Forward Declared Objective-C Interfaces and Protocols](https://github.com/apple/swift-evolution/blob/main/proposals/0384-importing-forward-declared-objc-interfaces-and-protocols.md)
    static let importObjcForwardDeclarations: Self = .enableUpcomingFeature("ImportObjcForwardDeclarations")
    /// Remove Actor Iscolation Inference caused by Property Wrappers
    /// - Version: Swift 5.9
    /// - Since: SwiftPM 5.9
    /// - SeeAlso: [SE-0401: Remove Actor Isolation Inference caused by Property Wrappers](https://github.com/apple/swift-evolution/blob/main/proposals/0401-remove-property-wrapper-isolation.md)
    static let disableOutwardActorInference: Self = .enableUpcomingFeature("DisableOutwardActorInference")
    /// Deprecate `@UIApplicationMain` and `@NSApplicationMain`
    /// - Version: Swift 5.10
    /// - Since: SwiftPM 5.10
    /// - SeeAlso: [SE-0383: Deprecate `@UIApplicationMain` and `@NSApplicationMain`](https://github.com/apple/swift-evolution/blob/main/proposals/0383-deprecate-uiapplicationmain-and-nsapplicationmain.md)
    static let deprecateApplicationMain: Self = .enableUpcomingFeature("DeprecateApplicationMain")
    /// Isolated default value expressions
    /// - Version: Swift 5.10
    /// - Since: SwiftPM 5.10
    /// - SeeAlso: [SE-0411: Isolated default value expressions](https://github.com/apple/swift-evolution/blob/main/proposals/0411-isolated-default-values.md)
    static let isolatedDefaultValues: Self = .enableUpcomingFeature("IsolatedDefaultValues")
    /// Strict concurrency for global variables
    /// - Version: Swift 5.10
    /// - Since: SwiftPM 5.10
    /// - SeeAlso: [SE-0412: Strict concurrency for global variables](https://github.com/apple/swift-evolution/blob/main/proposals/0412-strict-concurrency-for-global-variables.md)
    static let globalConcurrency: Self = .enableUpcomingFeature("GlobalConcurrency")
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
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "10.24.0")),
        .package(url: "https://github.com/maiyama18/LicensesPlugin.git", .upToNextMajor(from: "0.1.6")),
        .package(url: "https://github.com/vsanthanam/SafariUI.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", .upToNextMajor(from: "5.2.0")),
        .package(url: "https://github.com/realm/SwiftLint.git", .upToNextMajor(from: "0.54.0")),
        .package(url: "https://github.com/apple/swift-certificates.git", .upToNextMajor(from: "1.2.0")),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", .upToNextMajor(from: "1.10.2")),
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", .upToNextMajor(from: "1.2.2")),
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
let upcomingFeatures: [PackageDescription.SwiftSetting] = [
    .forwardTrailingClosures,
    .existentialAny,
    .bareSlashRegexLiterals,
    .conciseMagicFile,
    .importObjcForwardDeclarations,
    .disableOutwardActorInference,
    .deprecateApplicationMain,
    .isolatedDefaultValues,
    .globalConcurrency,
]

for target in package.targets {
    // swiftSettings
    target.swiftSettings = [
        .unsafeFlags(debugOtherSwiftFlags, .when(configuration: .debug)),
    ] + upcomingFeatures
    // plugins
    if let plugins = target.plugins {
        target.plugins = plugins + [.swiftLintPlugin]
    } else {
        target.plugins = [.swiftLintPlugin]
    }
}

// swiftlint:enable trailing_comma
