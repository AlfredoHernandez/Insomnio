//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppKit

public final class NSEventKeyEventMonitor: KeyEventMonitor, Sendable {
	public init() {}

	public func addGlobal(handler: @escaping (NSEvent) -> Void) -> Any? {
		NSEvent.addGlobalMonitorForEvents(matching: .keyDown, handler: handler)
	}

	public func addLocal(handler: @escaping (NSEvent) -> NSEvent?) -> Any? {
		NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: handler)
	}

	public func remove(_ token: Any) {
		NSEvent.removeMonitor(token)
	}
}
