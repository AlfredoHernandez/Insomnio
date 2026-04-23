//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppKit
import Automation
import Insomniac
import Premium
import Shortcut
import SwiftUI

@MainActor
final class AppCoordinator {
	private let dependencies: AppDependencies
	private var hasStarted = false
	private var menuBarController: MenuBarPopoverController?
	private nonisolated(unsafe) var terminationObserver: (any NSObjectProtocol)?
	/// The unstructured task kicked off by `start()` to load StoreKit products.
	/// Exposed so tests can `await` its completion deterministically instead of
	/// polling with `Task.yield()`.
	private(set) var bootstrapTask: Task<Void, Never>?

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
			dependencies.insomniac.toggle()
		}
		dependencies.automationCoordinator.startMonitoring()
		bootstrapTask = Task { [dependencies] in
			await dependencies.premiumManager.loadProducts()
		}

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
			premiumManager: dependencies.premiumManager,
			scheduleEvaluator: dependencies.scheduleEvaluator,
			appRulesEvaluator: dependencies.appRulesEvaluator,
			launchAtLoginManager: dependencies.launchAtLoginManager,
			accessibilityPermissionChecker: dependencies.accessibilityPermissionChecker,
			availableApps: dependencies.availableApps,
		)
	}

	private func observeTermination() {
		terminationObserver = NotificationCenter.default.addObserver(
			forName: NSApplication.willTerminateNotification,
			object: nil,
			queue: .main,
		) { [dependencies] _ in
			MainActor.assumeIsolated {
				dependencies.automationCoordinator.stopMonitoring()
				dependencies.insomniac.stop()
			}
		}
	}
}
