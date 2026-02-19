//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

class AppRulesEvaluatorPreviewStub: AppRulesEvaluator {
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
