//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public final class UserDefaultsRuleStore<Rule: Codable>: RuleStore {
	private let defaults: UserDefaults
	private let key: String

	public init(key: String, defaults: UserDefaults = .standard) {
		self.defaults = defaults
		self.key = key
	}

	public func loadRules() -> [Rule] {
		guard let data = defaults.data(forKey: key) else { return [] }
		return (try? JSONDecoder().decode([Rule].self, from: data)) ?? []
	}

	public func saveRules(_ rules: [Rule]) {
		let data = try? JSONEncoder().encode(rules)
		defaults.set(data, forKey: key)
	}
}
