// swift-tools-version: 6.2
import PackageDescription

let package = Package(
	name: "InsomnioKit",
	platforms: [.macOS(.v14)],
	products: [
		.library(name: "CursorPattern", targets: ["CursorPattern"]),
		.library(name: "RuleStore", targets: ["RuleStore"]),
		.library(name: "LaunchAtLogin", targets: ["LaunchAtLogin"]),
		.library(name: "TimerScheduler", targets: ["TimerScheduler"]),
		.library(name: "AccessibilityPermission", targets: ["AccessibilityPermission"]),
		.library(name: "Shortcut", targets: ["Shortcut"]),
		.library(name: "Premium", targets: ["Premium"]),
		.library(name: "AutoStop", targets: ["AutoStop"]),
		.library(name: "Schedule", targets: ["Schedule"]),
		.library(name: "AppRules", targets: ["AppRules"]),
		.library(name: "Insomniac", targets: ["Insomniac"]),
		.library(name: "Automation", targets: ["Automation"]),
		.library(name: "TestSupport", targets: ["TestSupport"]),
		.library(name: "TimerSchedulerTesting", targets: ["TimerSchedulerTesting"]),
		.library(name: "ScheduleTesting", targets: ["ScheduleTesting"]),
		.library(name: "RuleStoreTesting", targets: ["RuleStoreTesting"]),
	],
	targets: [
		.target(name: "CursorPattern"),
		.target(name: "RuleStore"),
		.target(name: "LaunchAtLogin"),
		.target(name: "TimerScheduler"),
		.target(name: "AccessibilityPermission"),
		.target(name: "Shortcut"),
		.target(name: "Premium"),
		.target(name: "AutoStop", dependencies: ["TimerScheduler"]),
		.target(name: "Schedule", dependencies: ["RuleStore"]),
		.target(name: "AppRules", dependencies: ["RuleStore"]),
		.target(name: "Insomniac", dependencies: ["AutoStop", "CursorPattern", "TimerScheduler"]),
		.target(name: "Automation", dependencies: ["AppRules", "Insomniac", "Schedule", "TimerScheduler"]),
		.target(name: "TestSupport"),
		.target(name: "TimerSchedulerTesting", dependencies: ["TimerScheduler"]),
		.target(name: "ScheduleTesting", dependencies: ["Schedule"]),
		.target(name: "RuleStoreTesting", dependencies: ["RuleStore"]),
		.testTarget(name: "CursorPatternTests", dependencies: ["CursorPattern"]),
		.testTarget(name: "RuleStoreTests", dependencies: ["RuleStore"]),
		.testTarget(name: "AutoStopTests", dependencies: ["AutoStop", "TestSupport", "TimerSchedulerTesting"]),
		.testTarget(name: "ScheduleTests", dependencies: ["Schedule", "ScheduleTesting", "RuleStoreTesting", "TestSupport"]),
	],
	swiftLanguageModes: [.v6],
)

for target in package.targets {
	var settings = target.swiftSettings ?? []
	settings.append(.defaultIsolation(MainActor.self))
	target.swiftSettings = settings
}
