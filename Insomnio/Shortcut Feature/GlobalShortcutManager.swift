//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

protocol GlobalShortcutManager {
	func registerShortcut(action: @escaping () -> Void)
	func unregisterShortcut()
}
