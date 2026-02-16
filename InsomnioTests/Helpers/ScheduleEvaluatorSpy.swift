//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import Foundation

@MainActor
final class ScheduleEvaluatorSpy: ScheduleEvaluator {
	var rules: [ScheduleRule] = []
	var stubbedShouldBeActive = false

	func shouldBeActive() -> Bool {
		stubbedShouldBeActive
	}

	func addRule(_ rule: ScheduleRule) {
		rules.append(rule)
	}

	func removeRule(id: UUID) {
		rules.removeAll { $0.id == id }
	}

	func updateRule(_: ScheduleRule) {}
}
