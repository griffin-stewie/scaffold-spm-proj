// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "scaffold-spm-proj",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(name: "scaffold-spm-proj", targets: ["CLI"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.4.0")),
        .package(url: "https://github.com/mxcl/Path.swift.git", .upToNextMinor(from: "1.4.0")),
        .package(url: "https://github.com/apple/swift-package-manager", .branch("swift-5.5.2-RELEASE")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "CLI",
            dependencies: [
                "Core",
                "Xcworkspace",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Path", package: "Path.swift"),
			]),
        .target(
            name: "Core",
            dependencies: [
                .product(name: "SwiftPM-auto", package: "swift-package-manager"),
            ]),
        .target(
            name: "Xcworkspace",
            dependencies: [
            ]),
        .testTarget(
            name: "scaffold-spm-projTests",
            dependencies: ["CLI"]),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"]),
        .testTarget(
            name: "XcworkspaceTests",
            dependencies: [
                "Xcworkspace",
                .product(name: "Path", package: "Path.swift"),
            ]),
    ]
)
