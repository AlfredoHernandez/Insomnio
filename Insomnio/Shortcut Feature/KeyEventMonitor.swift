//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppKit

/// Abstraction over `NSEvent.addGlobalMonitorForEvents` / `addLocalMonitorForEvents`
/// so `NSEventGlobalShortcutManager` can be tested without touching real AppKit
/// event monitors (which require UI context and return opaque tokens).
protocol KeyEventMonitor: Sendable {
	func addGlobal(handler: @escaping (NSEvent) -> Void) -> Any?
	func addLocal(handler: @escaping (NSEvent) -> NSEvent?) -> Any?
	func remove(_ token: Any)
}
