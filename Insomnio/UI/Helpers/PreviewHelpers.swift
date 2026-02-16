//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

#if DEBUG

class PreviewPremiumManager: PremiumManager {
	var isPremium = false
	func loadProducts() async {}
	func purchase(_: PremiumProduct) async throws -> Bool {
		true
	}

	func restorePurchases() async {}
}

class PreviewScheduleEvaluator: ScheduleEvaluator {
	var rules: [ScheduleRule] = []
	func shouldBeActive() -> Bool {
		false
	}

	func addRule(_: ScheduleRule) {}
	func removeRule(id _: UUID) {}
	func updateRule(_: ScheduleRule) {}
}

class PreviewAppRulesEvaluator: AppRulesEvaluator {
	var rules: [AppRule] = []
	func shouldBeActive() -> Bool {
		false
	}

	func addRule(_: AppRule) {}
	func removeRule(id _: UUID) {}
	func updateRule(_: AppRule) {}
}

class PreviewLaunchAtLoginManager: LaunchAtLoginManager {
	var isEnabled = false
	func enable() throws {}
	func disable() throws {}
}

#endif
