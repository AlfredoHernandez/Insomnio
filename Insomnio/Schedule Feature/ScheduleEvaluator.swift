//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

protocol ScheduleEvaluator: AnyObject {
	var rules: [ScheduleRule] { get }
	func shouldBeActive() -> Bool
	func addRule(_ rule: ScheduleRule)
	func removeRule(id: UUID)
	func updateRule(_ rule: ScheduleRule)
}
