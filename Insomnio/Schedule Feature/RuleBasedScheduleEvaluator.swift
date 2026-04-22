//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

@Observable
@MainActor
final class RuleBasedScheduleEvaluator: ScheduleEvaluator {
	private let dateProvider: DateProvider
	private let store: any RuleStore<ScheduleRule>
	var rules: [ScheduleRule]

	init(dateProvider: DateProvider, store: any RuleStore<ScheduleRule>) {
		self.dateProvider = dateProvider
		self.store = store
		rules = store.loadRules()
	}

	func shouldBeActive() -> Bool {
		let weekday = dateProvider.currentWeekday()
		let hour = dateProvider.currentHour()
		let minute = dateProvider.currentMinute()
		let currentMinutes = hour * 60 + minute

		return rules.contains { rule in
			guard rule.isEnabled else { return false }
			let start = rule.startHour * 60 + rule.startMinute
			let end = rule.endHour * 60 + rule.endMinute

			if start <= end {
				return rule.weekdays.contains(weekday)
					&& currentMinutes >= start
					&& currentMinutes < end
			} else {
				if currentMinutes >= start {
					return rule.weekdays.contains(weekday)
				} else if currentMinutes < end {
					return rule.weekdays.contains(weekday.previous)
				}
				return false
			}
		}
	}

	func addRule(_ rule: ScheduleRule) {
		rules.append(rule)
		store.saveRules(rules)
	}

	func removeRule(id: UUID) {
		rules.removeAll { $0.id == id }
		store.saveRules(rules)
	}

	func updateRule(_ rule: ScheduleRule) {
		guard let index = rules.firstIndex(where: { $0.id == rule.id }) else { return }
		rules[index] = rule
		store.saveRules(rules)
	}
}
