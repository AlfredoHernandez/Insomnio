//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppIntents

struct InsomnioShortcutsProvider: AppShortcutsProvider {
	static var appShortcuts: [AppShortcut] {
		AppShortcut(
			intent: StartInsomnioIntent(),
			phrases: [
				"Start \(.applicationName)",
				"Keep my Mac awake with \(.applicationName)",
			],
			shortTitle: "Start Insomnio",
			systemImageName: "sun.max.fill",
		)
		AppShortcut(
			intent: StopInsomnioIntent(),
			phrases: [
				"Stop \(.applicationName)",
				"Let my Mac sleep with \(.applicationName)",
			],
			shortTitle: "Stop Insomnio",
			systemImageName: "moon.fill",
		)
		AppShortcut(
			intent: ToggleInsomnioIntent(),
			phrases: [
				"Toggle \(.applicationName)",
			],
			shortTitle: "Toggle Insomnio",
			systemImageName: "power",
		)
		AppShortcut(
			intent: StartInsomnioForDurationIntent(),
			phrases: [
				"Start \(.applicationName) for a while",
				"Keep my Mac awake for a duration with \(.applicationName)",
			],
			shortTitle: "Start for Duration",
			systemImageName: "timer",
		)
	}
}
