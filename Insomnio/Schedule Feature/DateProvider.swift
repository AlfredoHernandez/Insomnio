//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

protocol DateProvider {
	func currentWeekday() -> Weekday
	func currentHour() -> Int
	func currentMinute() -> Int
}
