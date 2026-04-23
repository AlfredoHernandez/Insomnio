//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import Schedule

@MainActor
final class DateProviderSpy: DateProvider {
	var stubbedWeekday: Weekday = .monday
	var stubbedHour: Int = 12
	var stubbedMinute: Int = 0

	func currentWeekday() -> Weekday {
		stubbedWeekday
	}

	func currentHour() -> Int {
		stubbedHour
	}

	func currentMinute() -> Int {
		stubbedMinute
	}
}
