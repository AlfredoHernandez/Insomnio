//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct DateSnapshot: Equatable {
	public let weekday: Weekday
	public let hour: Int
	public let minute: Int

	public init(weekday: Weekday, hour: Int, minute: Int) {
		self.weekday = weekday
		self.hour = hour
		self.minute = minute
	}
}

public protocol DateProvider {
	func now() -> DateSnapshot
}
