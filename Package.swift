// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NOAAKit",
    platforms: [
        .macOS(.v12), .iOS(.v15 )
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "NOAAKit",
            targets: ["NOAAKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kraigspear/Spearfoundation.git", .branch("main")),
    ],
    targets: [
        .target(
            name: "NOAAKit",
            dependencies: [
                .product(name: "SpearFoundation", package: "Spearfoundation"),
            ]
        ),
        .testTarget(
            name: "NOAAKitTests",
            dependencies: ["NOAAKit"]),
    ]
)
