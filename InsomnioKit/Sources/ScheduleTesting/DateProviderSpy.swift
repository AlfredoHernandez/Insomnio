//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Schedule

public final class DateProviderSpy: DateProvider {
	public var stubbedWeekday: Weekday = .monday
	public var stubbedHour: Int = 12
	public var stubbedMinute: Int = 0

	public init() {}

	public func now() -> DateSnapshot {
		DateSnapshot(weekday: stubbedWeekday, hour: stubbedHour, minute: stubbedMinute)
	}
}
