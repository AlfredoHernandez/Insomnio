//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppKit

final class NSEventKeyEventMonitor: KeyEventMonitor, Sendable {
	func addGlobal(handler: @escaping (NSEvent) -> Void) -> Any? {
		NSEvent.addGlobalMonitorForEvents(matching: .keyDown, handler: handler)
	}

	func addLocal(handler: @escaping (NSEvent) -> NSEvent?) -> Any? {
		NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: handler)
	}

	func remove(_ token: Any) {
		NSEvent.removeMonitor(token)
	}
}
