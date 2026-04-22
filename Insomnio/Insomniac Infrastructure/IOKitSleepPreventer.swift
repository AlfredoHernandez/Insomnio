//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import IOKit.pwr_mgt
import OSLog

final class IOKitSleepPreventer: SleepPreventer {
	private nonisolated(unsafe) var assertionID: IOPMAssertionID = 0
	private nonisolated(unsafe) var isHolding = false
	private let logger = Logger(subsystem: "io.alfredohdz.Insomnio", category: "IOKitSleepPreventer")

	@discardableResult
	func createAssertion() -> Bool {
		guard !isHolding else { return true }
		let result = IOPMAssertionCreateWithName(
			kIOPMAssertPreventUserIdleDisplaySleep as CFString,
			IOPMAssertionLevel(kIOPMAssertionLevelOn),
			"Insomnio is keeping your Mac awake" as CFString,
			&assertionID,
		)
		isHolding = result == kIOReturnSuccess
		if !isHolding {
			logger.error("IOPMAssertionCreateWithName failed with code \(result, privacy: .public)")
		}
		return isHolding
	}

	func releaseAssertion() {
		guard isHolding else { return }
		IOPMAssertionRelease(assertionID)
		assertionID = 0
		isHolding = false
	}

	deinit {
		// Abrupt app termination: release the held assertion so it doesn't
		// outlive the process. Safe to call off the main actor because
		// IOPMAssertionRelease is thread-safe and `deinit` runs exactly once
		// after all other references are gone.
		if isHolding {
			IOPMAssertionRelease(assertionID)
		}
	}
}
