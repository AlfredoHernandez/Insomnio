//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct AppRule: Codable, Equatable, Identifiable {
	public let id: UUID
	public var bundleIdentifier: String
	public var displayName: String
	public var isEnabled: Bool

	public init(
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
