//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

@Observable
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
			MenuBarView(insomniac: dependencies.insomniac)
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
		)
	}
}
