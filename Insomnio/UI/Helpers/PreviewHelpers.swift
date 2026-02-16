//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

#if DEBUG

class StubPremiumManager: PremiumManager {
	var isPremium = false
	func loadProducts() async {}
	func purchase(_: PremiumProduct) async throws -> Bool {
		true
	}

	func restorePurchases() async {}
}

class StubScheduleEvaluator: ScheduleEvaluator {
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

class StubAppRulesEvaluator: AppRulesEvaluator {
	var rules: [AppRule] = []
	var stubbedShouldBeActive = false

	func shouldBeActive() -> Bool {
		stubbedShouldBeActive
	}

	func addRule(_ rule: AppRule) {
		rules.append(rule)
	}

	func removeRule(id: UUID) {
		rules.removeAll { $0.id == id }
	}

	func updateRule(_: AppRule) {}
}

class StubLaunchAtLoginManager: LaunchAtLoginManager {
	var isEnabled = false
	func enable() throws {}
	func disable() throws {}
}

#endif
