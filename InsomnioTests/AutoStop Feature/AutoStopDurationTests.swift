//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import Testing

@MainActor
@Suite("AutoStopDuration")
struct AutoStopDurationTests {
	@Test("thirtyMinutes returns 1800 seconds")
	func thirtyMinutes_returns1800Seconds() {
		#expect(AutoStopDuration.thirtyMinutes.seconds == 1800)
	}

	@Test("oneHour returns 3600 seconds")
	func oneHour_returns3600Seconds() {
		#expect(AutoStopDuration.oneHour.seconds == 3600)
	}

	@Test("twoHours returns 7200 seconds")
	func twoHours_returns7200Seconds() {
		#expect(AutoStopDuration.twoHours.seconds == 7200)
	}

	@Test("fourHours returns 14400 seconds")
	func fourHours_returns14400Seconds() {
		#expect(AutoStopDuration.fourHours.seconds == 14400)
	}

	@Test("custom returns specified seconds")
	func custom_returnsSpecifiedSeconds() {
		#expect(AutoStopDuration.custom(900).seconds == 900)
	}

	@Test("presets contains all preset durations")
	func presets_containsAllPresetDurations() {
		#expect(AutoStopDuration.presets == [.thirtyMinutes, .oneHour, .twoHours, .fourHours])
	}
}
