//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

final class UserDefaultsScheduleStore: ScheduleStore {
	private let defaults: UserDefaults
	private let key = "io.alfredohdz.Insomnio.scheduleRules"

	init(defaults: UserDefaults = .standard) {
		self.defaults = defaults
	}

	func loadRules() -> [ScheduleRule] {
		guard let data = defaults.data(forKey: key) else { return [] }
		return (try? JSONDecoder().decode([ScheduleRule].self, from: data)) ?? []
	}

	func saveRules(_ rules: [ScheduleRule]) {
		let data = try? JSONEncoder().encode(rules)
		defaults.set(data, forKey: key)
	}
}
