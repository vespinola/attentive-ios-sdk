// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "ExampleSwift",
    platforms: [
       .iOS(.v12)
    ],
    products: [
        .library(
            name: "ExampleSwift",
            targets: ["ExampleSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/attentive-mobile/attentive-ios-sdk", .branch("rsmith/support-swift"))
    ],
    targets: [
        .target(
            name: "ExampleSwift",
            dependencies: [
                .product(name: "attentive-ios-sdk", package: "attentive-ios-sdk")],
            path: "ExampleSwift" // Ensure this path exists and is correct
        ),
    ]
)
