//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

final class UserDefaultsPremiumStatusCache: PremiumStatusCache {
	private let defaults: UserDefaults
	private let key: String

	init(defaults: UserDefaults = .standard, key: String = "io.alfredohdz.Insomnio.isPremium") {
		self.defaults = defaults
		self.key = key
	}

	var isPremium: Bool {
		get { defaults.bool(forKey: key) }
		set { defaults.set(newValue, forKey: key) }
	}
}
