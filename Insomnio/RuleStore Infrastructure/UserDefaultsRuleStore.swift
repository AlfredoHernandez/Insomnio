//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

final class UserDefaultsRuleStore<Rule: Codable>: RuleStore {
	private let defaults: UserDefaults
	private let key: String

	init(key: String, defaults: UserDefaults = .standard) {
		self.defaults = defaults
		self.key = key
	}

	func loadRules() -> [Rule] {
		guard let data = defaults.data(forKey: key) else { return [] }
		return (try? JSONDecoder().decode([Rule].self, from: data)) ?? []
	}

	func saveRules(_ rules: [Rule]) {
		let data = try? JSONEncoder().encode(rules)
		defaults.set(data, forKey: key)
	}
}
