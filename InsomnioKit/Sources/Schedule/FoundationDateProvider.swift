//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public final class FoundationDateProvider: DateProvider {
	public init() {}

	public func now() -> DateSnapshot {
		let calendar = Calendar.current
		let date = Date()
		let components = calendar.dateComponents([.weekday, .hour, .minute], from: date)
		let weekday = Weekday(rawValue: components.weekday ?? 1) ?? .sunday
		return DateSnapshot(
			weekday: weekday,
			hour: components.hour ?? 0,
			minute: components.minute ?? 0,
		)
	}
}
