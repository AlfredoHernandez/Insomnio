//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppKit

/// Default isolation for the app target is `MainActor`, so the class-level
/// annotation is implicit.
final class AppDelegate: NSObject, NSApplicationDelegate {
	let coordinator = AppCoordinator(dependencies: .create())

	func applicationDidFinishLaunching(_: Notification) {
		coordinator.start()
	}

	func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
		false
	}
}
