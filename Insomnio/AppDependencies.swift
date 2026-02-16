//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

@MainActor
struct AppDependencies {
	let insomniac: Insomniac
	let premiumManager: any PremiumManager
	let scheduleEvaluator: any ScheduleEvaluator
	let appRulesEvaluator: any AppRulesEvaluator
	let automationCoordinator: AutomationCoordinator
	let shortcutManager: any GlobalShortcutManager

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

		return AppDependencies(
			insomniac: insomniac,
			premiumManager: premiumManager,
			scheduleEvaluator: scheduleEvaluator,
			appRulesEvaluator: appRulesEvaluator,
			automationCoordinator: automationCoordinator,
			shortcutManager: NSEventGlobalShortcutManager(),
		)
	}
}
