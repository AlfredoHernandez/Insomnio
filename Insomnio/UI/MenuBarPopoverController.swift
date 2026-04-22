//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppKit
import Observation
import SwiftUI

@MainActor
final class MenuBarPopoverController {
	private let statusItem: NSStatusItem
	private let popover: NSPopover
	private let actionHandler = ActionHandler()
	private var isObservingActive = false

	init(icon: String, @ViewBuilder content: () -> some View) {
		statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
		popover = NSPopover()
		popover.behavior = .transient
		popover.animates = true
		popover.contentViewController = NSHostingController(rootView: content())

		actionHandler.popover = popover
		actionHandler.statusItem = statusItem

		statusItem.button?.image = NSImage(systemSymbolName: icon, accessibilityDescription: "Insomnio")
		statusItem.button?.action = #selector(ActionHandler.togglePopover)
		statusItem.button?.target = actionHandler
	}

	func updateIcon(_ name: String) {
		statusItem.button?.image = NSImage(systemSymbolName: name, accessibilityDescription: "Insomnio")
	}

	func observeActive(_ insomniac: Insomniac) {
		guard !isObservingActive else { return }
		isObservingActive = true
		trackActiveChanges(insomniac)
	}

	private func trackActiveChanges(_ insomniac: Insomniac) {
		withObservationTracking {
			_ = insomniac.isActive
		} onChange: { [weak self] in
			Task { @MainActor in
				self?.updateIcon(insomniac.isActive ? "moon.zzz.fill" : "moon.zzz")
				self?.trackActiveChanges(insomniac)
			}
		}
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
