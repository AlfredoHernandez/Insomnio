//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

@MainActor
final class AppCoordinator {
	let dependencies: AppDependencies
	private var hasStarted = false
	private var menuBarController: MenuBarPopoverController?

	init(dependencies: AppDependencies) {
		self.dependencies = dependencies
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
	}

	func makeMainView() -> some View {
		InsomnioView(
			insomniac: dependencies.insomniac,
			premiumManager: dependencies.premiumManager,
			scheduleEvaluator: dependencies.scheduleEvaluator,
			appRulesEvaluator: dependencies.appRulesEvaluator,
			launchAtLoginManager: dependencies.launchAtLoginManager,
			availableApps: {
				NSWorkspace.shared.runningApplications
					.filter { $0.activationPolicy == .regular }
					.compactMap { app in
						guard let bundleID = app.bundleIdentifier else { return nil }
						let name = app.localizedName ?? bundleID
						let icon = app.icon ?? NSImage(
							systemSymbolName: "app",
							accessibilityDescription: nil,
						) ?? NSImage()
						return AppPickerView.AppInfo(bundleID: bundleID, name: name, icon: icon)
					}
			},
		)
	}
}
