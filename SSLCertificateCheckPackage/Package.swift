// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SSLCertificateCheckPackage",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "SSLCertificateCheckPackage",
            targets: ["SSLCertificateCheckPackage"]
        ),
    ],
    targets: [
        .target(
            name: "SSLCertificateCheckPackage"
        ),
        .testTarget(
            name: "SSLCertificateCheckPackageTests",
            dependencies: ["SSLCertificateCheckPackage"]
        ),
    ]
)
