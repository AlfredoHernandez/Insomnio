//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppIntents

struct ToggleInsomnioIntent: AppIntent {
	static let title: LocalizedStringResource = "Toggle Insomnio"
	static let description = IntentDescription("Toggles whether your Mac is being kept awake.")
	static let openAppWhenRun = false

	@MainActor
	func perform() async throws -> some IntentResult {
		IntentDependencies.performer?.toggle()
		return .result()
	}
}
