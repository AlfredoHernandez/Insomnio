//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

protocol AppRulesEvaluator: AnyObject {
	var rules: [AppRule] { get }
	func shouldBeActive() -> Bool
	func addRule(_ rule: AppRule)
	func removeRule(id: UUID)
	func updateRule(_ rule: AppRule)
}

@Observable
final class RunningAppRulesEvaluator: AppRulesEvaluator {
	private let runningAppProvider: RunningAppProvider
	private let store: any RuleStore<AppRule>
	var rules: [AppRule]

	init(runningAppProvider: RunningAppProvider, store: any RuleStore<AppRule>) {
		self.runningAppProvider = runningAppProvider
		self.store = store
		rules = store.loadRules()
	}

	func shouldBeActive() -> Bool {
		let running = runningAppProvider.runningAppBundleIdentifiers()
		return rules.contains { rule in
			rule.isEnabled && running.contains(rule.bundleIdentifier)
		}
	}

	func addRule(_ rule: AppRule) {
		rules.append(rule)
		store.saveRules(rules)
	}

	func removeRule(id: UUID) {
		rules.removeAll { $0.id == id }
		store.saveRules(rules)
	}

	func updateRule(_ rule: AppRule) {
		guard let index = rules.firstIndex(where: { $0.id == rule.id }) else { return }
		rules[index] = rule
		store.saveRules(rules)
	}
}
