//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import OSLog

public final class UserDefaultsRuleStore<Rule: Codable>: RuleStore {
	private let defaults: UserDefaults
	private let key: String
	private let logger = Logger(subsystem: "io.alfredohdz.Insomnio", category: "UserDefaultsRuleStore")

	public init(key: String, defaults: UserDefaults = .standard) {
		self.defaults = defaults
		self.key = key
	}

	public func loadRules() -> [Rule] {
		guard let data = defaults.data(forKey: key) else { return [] }
		return (try? JSONDecoder().decode([Rule].self, from: data)) ?? []
	}

	public func saveRules(_ rules: [Rule]) {
		do {
			let data = try JSONEncoder().encode(rules)
			defaults.set(data, forKey: key)
		} catch {
			// Preserve existing data on encode failure so a transient error
			// doesn't wipe the user's saved rules.
			logger.error("Failed to encode rules: \(error.localizedDescription, privacy: .public)")
		}
	}
}
