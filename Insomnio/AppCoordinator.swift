//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppKit
import SwiftUI

@MainActor
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

		dependencies.shortcutManager.registerShortcut { [dependencies] in
			dependencies.insomniac.toggle()
		}
		dependencies.automationCoordinator.startMonitoring()
		Task {
			await dependencies.premiumManager.loadProducts()
		}

		let controller = MenuBarPopoverController(icon: "moon.zzz") {
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
