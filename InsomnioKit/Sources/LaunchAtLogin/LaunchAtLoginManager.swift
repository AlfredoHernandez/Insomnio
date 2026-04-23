//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

public protocol LaunchAtLoginManager {
	var isEnabled: Bool { get }
	func enable() throws
	func disable() throws
}
