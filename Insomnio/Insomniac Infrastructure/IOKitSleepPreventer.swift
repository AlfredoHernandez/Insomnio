//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import IOKit.pwr_mgt

final class IOKitSleepPreventer: SleepPreventer {
	private var assertionID: IOPMAssertionID = 0
	private var isHolding = false

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
		return isHolding
	}

	func releaseAssertion() {
		guard isHolding else { return }
		IOPMAssertionRelease(assertionID)
		assertionID = 0
		isHolding = false
	}
}
