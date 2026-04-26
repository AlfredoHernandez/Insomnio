//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import RuleStore

@Observable
public final class RuleBasedScheduleEvaluator: ScheduleEvaluator {
	private let dateProvider: DateProvider
	private let store: any RuleStore<ScheduleRule>
	public var rules: [ScheduleRule]

	public init(dateProvider: DateProvider, store: any RuleStore<ScheduleRule>) {
		self.dateProvider = dateProvider
		self.store = store
		rules = store.loadRules()
	}

	public func shouldBeActive() -> Bool {
		let snapshot = dateProvider.now()
		let weekday = snapshot.weekday
		let currentMinutes = snapshot.hour * 60 + snapshot.minute

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

	public func addRule(_ rule: ScheduleRule) {
		rules.append(rule)
		store.saveRules(rules)
	}

	public func removeRule(id: UUID) {
		rules.removeAll { $0.id == id }
		store.saveRules(rules)
	}

	public func updateRule(_ rule: ScheduleRule) {
		guard let index = rules.firstIndex(where: { $0.id == rule.id }) else { return }
		rules[index] = rule
		store.saveRules(rules)
	}
}
