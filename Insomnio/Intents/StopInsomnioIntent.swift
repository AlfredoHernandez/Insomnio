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
		guard let performer = IntentDependencies.performer else {
			throw InsomnioIntentError.performerUnavailable
		}
		performer.stop()
		return .result()
	}
}
