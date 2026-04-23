//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Schedule

public final class DateProviderSpy: DateProvider {
	public var stubbedWeekday: Weekday = .monday
	public var stubbedHour: Int = 12
	public var stubbedMinute: Int = 0

	public init() {}

	public func currentWeekday() -> Weekday {
		stubbedWeekday
	}

	public func currentHour() -> Int {
		stubbedHour
	}

	public func currentMinute() -> Int {
		stubbedMinute
	}
}
