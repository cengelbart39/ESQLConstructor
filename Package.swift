// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ESQLConstructor",
    platforms: [.macOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ESQLConstructor",
            targets: ["ESQLConstructor"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0"),
        .package(url: "https://github.com/vapor/postgres-nio.git", from: "1.21.0"),
        .package(url: "https://github.com/ph1ps/swift-concurrency-deadline.git", from: "0.1.1"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ESQLConstructor",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "PostgresNIO", package: "postgres-nio"),
                .product(name: "Deadline", package: "swift-concurrency-deadline"),
                .product(name: "Collections", package: "swift-collections")
            ]
        ),
        .testTarget(
            name: "ESQLConstructorTests",
            dependencies: ["ESQLConstructor"]
        ),
        .executableTarget(
            name: "ESQLConstructorCLI",
            dependencies: [
                "ESQLConstructor",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        )
    ]
)
