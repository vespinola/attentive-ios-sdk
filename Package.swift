// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "AttentiveSdk",
	platforms: [.iOS(.v12)],
	products: [
		.library(name: "attentive-ios-sdk", targets: ["attentive-ios-sdk"])

	],
	targets: [
		.target(
			name: "attentive-ios-sdk",
			path: "Sources/"
		)
	]
)
