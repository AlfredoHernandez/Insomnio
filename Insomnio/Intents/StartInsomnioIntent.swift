//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppIntents

struct StartInsomnioIntent: AppIntent {
	static let title: LocalizedStringResource = "Start Insomnio"
	static let description = IntentDescription("Starts keeping your Mac awake.")
	static let openAppWhenRun = false

	@MainActor
	func perform() async throws -> some IntentResult {
		guard let performer = IntentDependencies.performer else {
			throw InsomnioIntentError.performerUnavailable
		}
		performer.start()
		return .result()
	}
}
