//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

struct ScheduleRule: Codable, Equatable, Identifiable {
	let id: UUID
	var weekdays: Set<Weekday>
	var startHour: Int
	var startMinute: Int
	var endHour: Int
	var endMinute: Int
	var isEnabled: Bool

	init(
		id: UUID = UUID(),
		weekdays: Set<Weekday> = [],
		startHour: Int = 9,
		startMinute: Int = 0,
		endHour: Int = 18,
		endMinute: Int = 0,
		isEnabled: Bool = true,
	) {
		self.id = id
		self.weekdays = weekdays
		self.startHour = startHour
		self.startMinute = startMinute
		self.endHour = endHour
		self.endMinute = endMinute
		self.isEnabled = isEnabled
	}
}

enum Weekday: Int, Codable, CaseIterable, Comparable {
	case sunday = 1
	case monday = 2
	case tuesday = 3
	case wednesday = 4
	case thursday = 5
	case friday = 6
	case saturday = 7

	static func < (lhs: Weekday, rhs: Weekday) -> Bool {
		lhs.rawValue < rhs.rawValue
	}

	var previous: Weekday {
		Weekday(rawValue: rawValue == 1 ? 7 : rawValue - 1)!
	}
}
