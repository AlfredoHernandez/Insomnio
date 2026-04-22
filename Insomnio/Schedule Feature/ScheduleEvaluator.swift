//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

protocol ScheduleRuleEvaluating: AnyObject {
	func shouldBeActive() -> Bool
}

protocol ScheduleEvaluator: ScheduleRuleEvaluating {
	var rules: [ScheduleRule] { get }
	func addRule(_ rule: ScheduleRule)
	func removeRule(id: UUID)
	func updateRule(_ rule: ScheduleRule)
}
