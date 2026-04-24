//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppKit
import Insomniac
import Observation
import SwiftUI

final class MenuBarPopoverController {
	enum IconState {
		case idle
		case active
		case activeWithAutoStop

		var symbolName: String {
			switch self {
			case .idle: "moon.zzz"
			case .active: "moon.zzz.fill"
			case .activeWithAutoStop: "hourglass"
			}
		}
	}

	private let statusItem: NSStatusItem
	private let popover: NSPopover
	private let actionHandler = ActionHandler()
	private var isObservingActive = false

	init(initialState: IconState = .idle, @ViewBuilder content: () -> some View) {
		statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
		popover = NSPopover()
		popover.behavior = .transient
		popover.animates = true
		popover.contentViewController = NSHostingController(rootView: content())

		actionHandler.popover = popover
		actionHandler.statusItem = statusItem

		statusItem.button?.image = NSImage(systemSymbolName: initialState.symbolName, accessibilityDescription: "Insomnio")
		statusItem.button?.action = #selector(ActionHandler.togglePopover)
		statusItem.button?.target = actionHandler
	}

	func updateIcon(_ state: IconState) {
		statusItem.button?.image = NSImage(systemSymbolName: state.symbolName, accessibilityDescription: "Insomnio")
	}

	func observeActive(_ insomniac: Insomniac) {
		guard !isObservingActive else { return }
		isObservingActive = true
		trackActiveChanges(insomniac)
	}

	private func trackActiveChanges(_ insomniac: Insomniac) {
		withObservationTracking {
			_ = insomniac.isActive
			_ = insomniac.autoStopIsRunning
		} onChange: { [weak self] in
			// `onChange` fires from the Observation runtime in a nonisolated
			// context, so the hop to `@MainActor` is required — without it the
			// task inherits the nonisolated caller and cannot reach
			// `updateIcon` / `trackActiveChanges`.
			Task { @MainActor in
				self?.updateIcon(Self.iconState(for: insomniac))
				self?.trackActiveChanges(insomniac)
			}
		}
	}

	private static func iconState(for insomniac: Insomniac) -> IconState {
		guard insomniac.isActive else { return .idle }
		return insomniac.autoStopIsRunning ? .activeWithAutoStop : .active
	}
}

private class ActionHandler: NSObject {
	var popover: NSPopover?
	var statusItem: NSStatusItem?

	@objc func togglePopover() {
		guard let popover, let button = statusItem?.button else { return }
		if popover.isShown {
			popover.close()
		} else {
			popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
			popover.contentViewController?.view.window?.makeKey()
		}
	}
}
