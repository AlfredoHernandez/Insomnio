//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AutoStop
import Foundation
import Testing

@MainActor
struct AutoStopDurationTests {
	@Test(arguments: [
		(AutoStopDuration.thirtyMinutes, TimeInterval(1800)),
		(.oneHour, TimeInterval(3600)),
		(.twoHours, TimeInterval(7200)),
		(.fourHours, TimeInterval(14400)),
	])
	func `Duration maps to expected seconds`(duration: AutoStopDuration, seconds: TimeInterval) {
		#expect(duration.seconds == seconds)
	}

	@Test
	func `presets contains all preset durations`() {
		#expect(AutoStopDuration.presets == [.thirtyMinutes, .oneHour, .twoHours, .fourHours])
	}
}
