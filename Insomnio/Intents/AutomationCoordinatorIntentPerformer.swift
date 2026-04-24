//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AutoStop
import Insomniac

/// Concrete `InsomnioIntentPerformer` that routes App Intent actions to the
/// shared `Insomniac` model.
///
/// Intents are treated as manual user input: `start` and `stop` invoke
/// `Insomniac.toggle()` when a state change is required so the
/// `AutomationCoordinator`'s `onToggle` hook registers a manual override and
/// does not immediately revert the user's intent on the next evaluation tick.
final class AutomationCoordinatorIntentPerformer: InsomnioIntentPerformer {
	private let insomniac: Insomniac

	init(insomniac: Insomniac) {
		self.insomniac = insomniac
	}

	func start() {
		guard !insomniac.isActive else { return }
		insomniac.toggle()
	}

	func stop() {
		guard insomniac.isActive else { return }
		insomniac.toggle()
	}

	func toggle() {
		insomniac.toggle()
	}

	func startForDuration(_ duration: AutoStopDuration) {
		// Stop first when already active so the in-flight auto-stop timer is
		// cancelled; otherwise the new `autoStopDuration` is applied to the
		// model but the original countdown keeps running and Insomnio shuts
		// off at the old time.
		stop()
		insomniac.autoStopEnabled = true
		insomniac.autoStopDuration = duration
		start()
	}
}
