//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppKit
import Automation
import Insomniac
import Shortcut
import SwiftUI

final class AppCoordinator {
	private let dependencies: AppDependencies
	private var hasStarted = false
	private var menuBarController: MenuBarPopoverController?
	private nonisolated(unsafe) var terminationObserver: (any NSObjectProtocol)?

	init(dependencies: AppDependencies) {
		self.dependencies = dependencies
	}

	deinit {
		// `NotificationCenter.removeObserver` is thread-safe and `deinit`
		// runs exactly once; the `nonisolated(unsafe)` capture above is
		// safe because no other context can still reach this instance.
		if let terminationObserver {
			NotificationCenter.default.removeObserver(terminationObserver)
		}
	}

	func start() {
		guard !hasStarted else { return }
		hasStarted = true

		IntentDependencies.performer = AutomationCoordinatorIntentPerformer(insomniac: dependencies.insomniac)
		dependencies.shortcutManager.registerShortcut { [dependencies] in
			dependencies.insomniac.toggle(from: .globalShortcut)
		}
		dependencies.automationCoordinator.startMonitoring()

		let controller = MenuBarPopoverController(initialState: .idle) {
			MenuBarView(
				insomniac: dependencies.insomniac,
				activateApp: { NSApplication.shared.activate(ignoringOtherApps: true) },
				quitApp: { NSApplication.shared.terminate(nil) },
			)
		}
		controller.observeActive(dependencies.insomniac)
		menuBarController = controller

		observeTermination()
	}

	func makeMainView() -> some View {
		InsomnioView(
			insomniac: dependencies.insomniac,
			scheduleEvaluator: dependencies.scheduleEvaluator,
			appRulesEvaluator: dependencies.appRulesEvaluator,
			launchAtLoginManager: dependencies.launchAtLoginManager,
			accessibilityPermissionChecker: dependencies.accessibilityPermissionChecker,
			availableApps: dependencies.availableApps,
		)
	}

	private func observeTermination() {
		// `queue: nil` dispatches the handler synchronously on the posting
		// thread. `NSApplication.willTerminateNotification` is always posted
		// by AppKit on the main thread, so the handler lands on the main
		// actor and `MainActor.assumeIsolated` is a safe compiler bridge.
		// Synchronous delivery also lets tests observe the side effects
		// immediately after `post(...)` without any polling.
		// Capturing `dependencies` explicitly (value-ish struct) avoids
		// retaining `self`.
		terminationObserver = NotificationCenter.default.addObserver(
			forName: NSApplication.willTerminateNotification,
			object: nil,
			queue: nil,
		) { [dependencies] _ in
			MainActor.assumeIsolated {
				dependencies.automationCoordinator.stopMonitoring()
				dependencies.insomniac.stop()
			}
		}
	}
}
