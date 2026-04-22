//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppKit
import OSLog

final class NSEventGlobalShortcutManager: GlobalShortcutManager {
	private let logger = Logger(subsystem: "io.alfredohdz.Insomnio", category: "NSEventGlobalShortcutManager")
	// `globalMonitor` and `localMonitor` store opaque NSEvent monitor tokens
	// (non-Sendable `Any?`). They are written/read from the MainActor during
	// register/unregister and read from `deinit` (nonisolated in Swift 6).
	// `deinit` runs at most once after all other references are released, so
	// there is no concurrent access; `nonisolated(unsafe)` is the standard
	// escape hatch for this pattern with non-Sendable payloads.
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
		if globalMonitor == nil {
			logger.error("Failed to register global key monitor for Insomnio shortcut")
		}

		localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
			guard let self, matchesShortcut(event) else { return event }
			action()
			return nil
		}
		if localMonitor == nil {
			logger.error("Failed to register local key monitor for Insomnio shortcut")
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
		// `NSEvent.removeMonitor` must run on the main thread. `deinit` is
		// nonisolated in Swift 6 and may fire wherever the last reference is
		// released, so we capture the tokens and hop to the main queue.
		let tokens = [globalMonitor, localMonitor].compactMap(\.self)
		DispatchQueue.main.async {
			tokens.forEach { NSEvent.removeMonitor($0) }
		}
	}

	private func matchesShortcut(_ event: NSEvent) -> Bool {
		event.keyCode == keyCode
			&& event.modifierFlags.intersection(.deviceIndependentFlagsMask).contains(requiredFlags)
	}
}
