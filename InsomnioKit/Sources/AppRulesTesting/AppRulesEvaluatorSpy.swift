//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppRules
import Foundation

public final class AppRulesEvaluatorSpy: @MainActor AppRulesEvaluator {
	public var rules: [AppRule] = []
	public var stubbedShouldBeActive = false

	public init() {}

	public func shouldBeActive() -> Bool {
		stubbedShouldBeActive
	}

	public func addRule(_ rule: AppRule) {
		rules.append(rule)
	}

	public func removeRule(id: UUID) {
		rules.removeAll { $0.id == id }
	}

	public func updateRule(_: AppRule) {}
}
