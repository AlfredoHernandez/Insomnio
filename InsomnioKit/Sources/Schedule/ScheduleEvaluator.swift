//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public protocol ScheduleRuleEvaluating: AnyObject {
	func shouldBeActive() -> Bool
}

public protocol ScheduleEvaluator: ScheduleRuleEvaluating {
	var rules: [ScheduleRule] { get }
	func addRule(_ rule: ScheduleRule)
	func removeRule(id: UUID)
	func updateRule(_ rule: ScheduleRule)
}
