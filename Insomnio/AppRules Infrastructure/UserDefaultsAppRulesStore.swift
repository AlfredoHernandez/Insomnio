//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

protocol AppRulesStore {
	func loadRules() -> [AppRule]
	func saveRules(_ rules: [AppRule])
}

final class UserDefaultsAppRulesStore: AppRulesStore {
	private let defaults: UserDefaults
	private let key = "io.alfredohdz.Insomnio.appRules"

	init(defaults: UserDefaults = .standard) {
		self.defaults = defaults
	}

	func loadRules() -> [AppRule] {
		guard let data = defaults.data(forKey: key) else { return [] }
		return (try? JSONDecoder().decode([AppRule].self, from: data)) ?? []
	}

	func saveRules(_ rules: [AppRule]) {
		let data = try? JSONEncoder().encode(rules)
		defaults.set(data, forKey: key)
	}
}
