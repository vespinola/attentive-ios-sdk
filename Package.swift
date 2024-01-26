// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "Attentive",
	platforms: [.iOS(.v12), .macOS(.v10_15), .tvOS(.v13)],
	products: [
		.library(name: "Attentive", targets: ["attentive-ios-sdk"])
	],
	targets: [
		.target(
			name: "attentive-ios-sdk",
			path: "Sources/"
		)
	]
)
