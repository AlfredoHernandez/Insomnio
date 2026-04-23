//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import Schedule

public final class ScheduleEvaluatorSpy: @MainActor ScheduleEvaluator {
	public var rules: [ScheduleRule] = []
	public var stubbedShouldBeActive = false

	public init() {}

	public func shouldBeActive() -> Bool {
		stubbedShouldBeActive
	}

	public func addRule(_ rule: ScheduleRule) {
		rules.append(rule)
	}

	public func removeRule(id: UUID) {
		rules.removeAll { $0.id == id }
	}

	public func updateRule(_: ScheduleRule) {}
}
