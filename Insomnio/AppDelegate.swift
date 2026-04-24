//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
	let coordinator = AppCoordinator(dependencies: .create())

	nonisolated func applicationDidFinishLaunching(_: Notification) {
		MainActor.assumeIsolated {
			coordinator.start()
		}
	}

	func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
		false
	}
}
