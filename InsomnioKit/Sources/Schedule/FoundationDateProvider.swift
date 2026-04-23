//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public final class FoundationDateProvider: DateProvider {
	public init() {}

	public func currentWeekday() -> Weekday {
		let component = Calendar.current.component(.weekday, from: Date())
		return Weekday(rawValue: component) ?? .sunday
	}

	public func currentHour() -> Int {
		Calendar.current.component(.hour, from: Date())
	}

	public func currentMinute() -> Int {
		Calendar.current.component(.minute, from: Date())
	}
}
