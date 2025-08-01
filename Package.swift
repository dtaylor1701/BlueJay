// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BlueJay",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
    .tvOS(.v16),
    .watchOS(.v7),
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "BlueJay",
      targets: ["BlueJay"])
  ],
  dependencies: [
    .package(url: "https://github.com/dtaylor1701/Goose.git", .upToNextMajor(from: "1.0.0"))
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "BlueJay",
      dependencies: [
        .product(name: "Goose", package: "Goose")
      ]
    ),
    .testTarget(
      name: "BlueJayTests",
      dependencies: ["BlueJay"]),
  ]
)
