//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct ScheduleRule: Codable, Equatable, Identifiable {
	public let id: UUID
	public var weekdays: Set<Weekday>
	public var startHour: Int
	public var startMinute: Int
	public var endHour: Int
	public var endMinute: Int
	public var isEnabled: Bool

	public init(
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

public enum Weekday: Int, Codable, CaseIterable, Comparable {
	case sunday = 1
	case monday = 2
	case tuesday = 3
	case wednesday = 4
	case thursday = 5
	case friday = 6
	case saturday = 7

	public static func < (lhs: Weekday, rhs: Weekday) -> Bool {
		lhs.rawValue < rhs.rawValue
	}

	public var previous: Weekday {
		Weekday(rawValue: rawValue == 1 ? 7 : rawValue - 1) ?? self
	}

	public var shortLabel: String {
		let symbols = Calendar.current.veryShortStandaloneWeekdaySymbols
		let index = rawValue - 1
		guard symbols.indices.contains(index) else { return "" }
		return symbols[index]
	}
}
