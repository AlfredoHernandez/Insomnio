//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppKit
import OSLog

public final class NSEventGlobalShortcutManager: GlobalShortcutManager {
	private let logger = Logger(subsystem: "io.alfredohdz.Insomnio", category: "NSEventGlobalShortcutManager")
	private let monitor: any KeyEventMonitor
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

	public init(monitor: any KeyEventMonitor = NSEventKeyEventMonitor()) {
		self.monitor = monitor
	}

	public func registerShortcut(action: @escaping () -> Void) {
		unregisterShortcut()

		globalMonitor = monitor.addGlobal { [weak self] event in
			guard let self, matchesShortcut(event) else { return }
			action()
		}
		if globalMonitor == nil {
			logger.error("Failed to register global key monitor for Insomnio shortcut")
		}

		localMonitor = monitor.addLocal { [weak self] event in
			guard let self, matchesShortcut(event) else { return event }
			action()
			return nil
		}
		if localMonitor == nil {
			logger.error("Failed to register local key monitor for Insomnio shortcut")
		}
	}

	public func unregisterShortcut() {
		if let globalMonitor {
			monitor.remove(globalMonitor)
		}
		globalMonitor = nil

		if let localMonitor {
			monitor.remove(localMonitor)
		}
		localMonitor = nil
	}

	deinit {
		// `NSEvent.removeMonitor` must run on the main thread. `deinit` is
		// nonisolated in Swift 6 and may fire wherever the last reference is
		// released, so we capture the tokens and hop to the main queue. The
		// injected `monitor` is `Sendable`, letting us route cleanup through
		// the same abstraction as the register/unregister path.
		let tokens = [globalMonitor, localMonitor].compactMap(\.self)
		let monitor = self.monitor
		nonisolated(unsafe) let unsafeTokens = tokens
		DispatchQueue.main.async {
			unsafeTokens.forEach { monitor.remove($0) }
		}
	}

	private func matchesShortcut(_ event: NSEvent) -> Bool {
		event.keyCode == keyCode
			&& event.modifierFlags.intersection(.deviceIndependentFlagsMask).contains(requiredFlags)
	}
}
