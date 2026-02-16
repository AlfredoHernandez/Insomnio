//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

@MainActor
struct AppDependencies {
	let insomniac: Insomniac
	let premiumManager: any PremiumManager
	let scheduleEvaluator: any ScheduleEvaluator
	let appRulesEvaluator: any AppRulesEvaluator
	let automationCoordinator: AutomationCoordinator
	let shortcutManager: any GlobalShortcutManager
	let menuBarController: MenuBarPopoverController

	static func create() -> AppDependencies {
		let insomniac = Insomniac(
			mouseMover: CGMouseMover(),
			sleepPreventer: IOKitSleepPreventer(),
			idleTimeProvider: CGIdleTimeProvider(),
			powerSourceProvider: IOKitPowerSourceProvider(),
			autoStopTimer: FoundationAutoStopTimer(),
		)

		let scheduleEvaluator = ScheduleEvaluatorImpl(
			dateProvider: FoundationDateProvider(),
			store: UserDefaultsScheduleStore(),
		)

		let appRulesEvaluator = AppRulesEvaluatorImpl(
			runningAppProvider: NSWorkspaceRunningAppProvider(),
			store: UserDefaultsAppRulesStore(),
		)

		let automationCoordinator = AutomationCoordinator(
			scheduleEvaluator: scheduleEvaluator,
			appRulesEvaluator: appRulesEvaluator,
			insomniac: insomniac,
		)

		let premiumManager: any PremiumManager = {
			#if DEBUG
			DebugPremiumManager()
			#else
			StoreKitPremiumManager()
			#endif
		}()

		let menuBarController = MenuBarPopoverController(icon: "moon.zzz") {
			MenuBarView(
				insomniac: insomniac,
				onManualToggle: { automationCoordinator.notifyManualToggle() },
			)
		}
		menuBarController.observeActive(insomniac)

		return AppDependencies(
			insomniac: insomniac,
			premiumManager: premiumManager,
			scheduleEvaluator: scheduleEvaluator,
			appRulesEvaluator: appRulesEvaluator,
			automationCoordinator: automationCoordinator,
			shortcutManager: NSEventGlobalShortcutManager(),
			menuBarController: menuBarController,
		)
	}
}
