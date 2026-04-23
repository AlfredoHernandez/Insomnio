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
		IntentDependencies.performer?.start()
		return .result()
	}
}
