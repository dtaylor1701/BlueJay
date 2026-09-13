// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BlueJay",
  platforms: [
    .iOS(.v18),
    .macOS(.v15),
    .tvOS(.v18),
    .watchOS(.v11),
  ],
  products: [
    .library(
      name: "BlueJay",
      targets: ["BlueJay"])
  ],
  dependencies: [
    .package(path: "../Goose"),
    .package(path: "../Crow"),
    .package(url: "https://github.com/swiftlang/swift-markdown.git", from: "0.5.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "BlueJay",
      dependencies: [
        .product(name: "Goose", package: "Goose"),
        .product(name: "Crow", package: "Crow"),
        .product(name: "Markdown", package: "swift-markdown"),
      ]
    ),
    .testTarget(
      name: "BlueJayTests",
      dependencies: ["BlueJay"]),
  ],
  swiftLanguageModes: [.v5]
)
