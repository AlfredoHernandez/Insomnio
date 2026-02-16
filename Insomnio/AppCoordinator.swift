//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

@Observable
final class AppCoordinator {
	let dependencies: AppDependencies
	private var hasStarted = false

	init(dependencies: AppDependencies) {
		self.dependencies = dependencies
	}

	func start() {
		guard !hasStarted else { return }
		hasStarted = true

		dependencies.shortcutManager.registerShortcut { [dependencies] in
			dependencies.insomniac.toggle()
			dependencies.automationCoordinator.notifyManualToggle()
		}
		dependencies.automationCoordinator.startMonitoring()
		Task {
			await dependencies.premiumManager.loadProducts()
		}
	}

	func makeMainView() -> some View {
		InsomnioView(
			insomniac: dependencies.insomniac,
			premiumManager: dependencies.premiumManager,
			scheduleEvaluator: dependencies.scheduleEvaluator,
			appRulesEvaluator: dependencies.appRulesEvaluator,
			onManualToggle: { [dependencies] in
				dependencies.automationCoordinator.notifyManualToggle()
			},
		)
	}
}
