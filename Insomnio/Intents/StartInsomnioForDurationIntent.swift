//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppIntents

/// A future `StartUntilBatteryBelowIntent` is a natural premium-gated candidate;
/// the four intents shipped in this module are intentionally free.
struct StartInsomnioForDurationIntent: AppIntent {
	static let title: LocalizedStringResource = "Start Insomnio for Duration"
	static let description = IntentDescription("Starts keeping your Mac awake for a fixed amount of time.")
	static let openAppWhenRun = false

	@Parameter(title: "Duration")
	var duration: AutoStopDurationAppEnum

	@MainActor
	func perform() async throws -> some IntentResult {
		IntentDependencies.performer?.startForDuration(duration.domainValue)
		return .result()
	}
}
