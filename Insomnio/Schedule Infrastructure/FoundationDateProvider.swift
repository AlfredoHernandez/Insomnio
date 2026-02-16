//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

final class FoundationDateProvider: DateProvider {
	func currentWeekday() -> Weekday {
		let component = Calendar.current.component(.weekday, from: Date())
		return Weekday(rawValue: component) ?? .sunday
	}

	func currentHour() -> Int {
		Calendar.current.component(.hour, from: Date())
	}

	func currentMinute() -> Int {
		Calendar.current.component(.minute, from: Date())
	}
}
