// swift-tools-version: 6.2
import PackageDescription

let package = Package(
	name: "InsomnioKit",
	platforms: [.macOS(.v14)],
	products: [
		.library(name: "CursorPattern", targets: ["CursorPattern"]),
		.library(name: "RuleStore", targets: ["RuleStore"]),
		.library(name: "LaunchAtLogin", targets: ["LaunchAtLogin"]),
	],
	targets: [
		.target(name: "CursorPattern"),
		.target(name: "RuleStore"),
		.target(name: "LaunchAtLogin"),
		.testTarget(name: "CursorPatternTests", dependencies: ["CursorPattern"]),
		.testTarget(name: "RuleStoreTests", dependencies: ["RuleStore"]),
	],
	swiftLanguageModes: [.v6],
)

for target in package.targets {
	var settings = target.swiftSettings ?? []
	settings.append(.defaultIsolation(MainActor.self))
	target.swiftSettings = settings
}
