//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppIntents

struct StartInsomnioForDurationIntent: AppIntent {
	static let title: LocalizedStringResource = "Start Insomnio for Duration"
	static let description = IntentDescription("Starts keeping your Mac awake for a fixed amount of time.")
	static let openAppWhenRun = false

	@Parameter(title: "Duration")
	var duration: AutoStopDurationAppEnum

	@MainActor
	func perform() async throws -> some IntentResult {
		guard let performer = IntentDependencies.performer else {
			throw InsomnioIntentError.performerUnavailable
		}
		performer.startForDuration(duration.domainValue)
		return .result()
	}
}
