//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import RuleStore

@Observable
public final class RunningAppRulesEvaluator: AppRulesEvaluator {
	private let runningAppProvider: RunningAppProvider
	private let store: any RuleStore<AppRule>
	public var rules: [AppRule]

	public init(runningAppProvider: RunningAppProvider, store: any RuleStore<AppRule>) {
		self.runningAppProvider = runningAppProvider
		self.store = store
		rules = store.loadRules()
	}

	public func shouldBeActive() -> Bool {
		let running = runningAppProvider.runningAppBundleIdentifiers()
		return rules.contains { rule in
			rule.isEnabled && running.contains(rule.bundleIdentifier)
		}
	}

	public func addRule(_ rule: AppRule) {
		rules.append(rule)
		store.saveRules(rules)
	}

	public func removeRule(id: UUID) {
		rules.removeAll { $0.id == id }
		store.saveRules(rules)
	}

	public func updateRule(_ rule: AppRule) {
		guard let index = rules.firstIndex(where: { $0.id == rule.id }) else { return }
		rules[index] = rule
		store.saveRules(rules)
	}
}
