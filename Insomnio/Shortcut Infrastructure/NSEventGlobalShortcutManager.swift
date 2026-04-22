//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppKit

final class NSEventGlobalShortcutManager: GlobalShortcutManager {
	private nonisolated(unsafe) var globalMonitor: Any?
	private nonisolated(unsafe) var localMonitor: Any?

	// ⌃⌥⌘I
	private let requiredFlags: NSEvent.ModifierFlags = [.control, .option, .command]
	private let keyCode: UInt16 = 34

	func registerShortcut(action: @escaping () -> Void) {
		unregisterShortcut()

		globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
			guard let self, matchesShortcut(event) else { return }
			action()
		}

		localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
			guard let self, matchesShortcut(event) else { return event }
			action()
			return nil
		}
	}

	func unregisterShortcut() {
		if let globalMonitor {
			NSEvent.removeMonitor(globalMonitor)
		}
		globalMonitor = nil

		if let localMonitor {
			NSEvent.removeMonitor(localMonitor)
		}
		localMonitor = nil
	}

	deinit {
		if let globalMonitor {
			NSEvent.removeMonitor(globalMonitor)
		}
		if let localMonitor {
			NSEvent.removeMonitor(localMonitor)
		}
	}

	private func matchesShortcut(_ event: NSEvent) -> Bool {
		event.keyCode == keyCode
			&& event.modifierFlags.intersection(.deviceIndependentFlagsMask).contains(requiredFlags)
	}
}
