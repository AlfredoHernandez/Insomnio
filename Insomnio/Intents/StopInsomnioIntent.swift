//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppIntents

struct StopInsomnioIntent: AppIntent {
	static let title: LocalizedStringResource = "Stop Insomnio"
	static let description = IntentDescription("Stops keeping your Mac awake.")
	static let openAppWhenRun = false

	@MainActor
	func perform() async throws -> some IntentResult {
		IntentDependencies.performer?.stop()
		return .result()
	}
}
