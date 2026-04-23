//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AutoStop
import Testing

@MainActor
struct AutoStopDurationTests {
	@Test
	func `thirtyMinutes returns 1800 seconds`() {
		#expect(AutoStopDuration.thirtyMinutes.seconds == 1800)
	}

	@Test
	func `oneHour returns 3600 seconds`() {
		#expect(AutoStopDuration.oneHour.seconds == 3600)
	}

	@Test
	func `twoHours returns 7200 seconds`() {
		#expect(AutoStopDuration.twoHours.seconds == 7200)
	}

	@Test
	func `fourHours returns 14400 seconds`() {
		#expect(AutoStopDuration.fourHours.seconds == 14400)
	}

	@Test
	func `presets contains all preset durations`() {
		#expect(AutoStopDuration.presets == [.thirtyMinutes, .oneHour, .twoHours, .fourHours])
	}
}
