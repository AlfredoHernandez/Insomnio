//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

struct AppRule: Codable, Equatable, Identifiable {
	let id: UUID
	var bundleIdentifier: String
	var displayName: String
	var isEnabled: Bool

	init(
		id: UUID = UUID(),
		bundleIdentifier: String,
		displayName: String,
		isEnabled: Bool = true,
	) {
		self.id = id
		self.bundleIdentifier = bundleIdentifier
		self.displayName = displayName
		self.isEnabled = isEnabled
	}
}
