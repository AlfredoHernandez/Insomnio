//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AccessibilityPermission
import AppRules
import Automation
import AutoStop
import Foundation
import Insomniac
import LaunchAtLogin
import RuleStore
import Schedule
import Shortcut
import TimerScheduler

struct AppDependencies {
	let insomniac: Insomniac
	let scheduleEvaluator: any ScheduleEvaluator
	let appRulesEvaluator: any AppRulesEvaluator
	let automationCoordinator: any AutomationCoordinating
	let shortcutManager: any GlobalShortcutManager
	let launchAtLoginManager: any LaunchAtLoginManager
	let accessibilityPermissionChecker: any AccessibilityPermissionChecker
	let availableApps: () -> [AppInfo]

	static func create() -> AppDependencies {
		let timerScheduler = FoundationTimerScheduler()

		let insomniac = Insomniac(
			mouseMover: CGMouseMover(),
			sleepPreventer: IOKitSleepPreventer(),
			idleTimeProvider: CGIdleTimeProvider(),
			powerSourceProvider: IOKitPowerSourceProvider(),
			autoStopTimer: FoundationAutoStopTimer(timerScheduler: timerScheduler),
			timerScheduler: timerScheduler,
		)

		let scheduleEvaluator = RuleBasedScheduleEvaluator(
			dateProvider: FoundationDateProvider(),
			store: UserDefaultsRuleStore<ScheduleRule>(key: "io.alfredohdz.Insomnio.scheduleRules"),
		)

		let appRulesEvaluator = RunningAppRulesEvaluator(
			runningAppProvider: NSWorkspaceRunningAppProvider(),
			store: UserDefaultsRuleStore<AppRule>(key: "io.alfredohdz.Insomnio.appRules"),
		)

		let automationCoordinator = AutomationCoordinator(
			scheduleEvaluator: scheduleEvaluator,
			appRulesEvaluator: appRulesEvaluator,
			insomniac: insomniac,
			timerScheduler: timerScheduler,
		)

		return AppDependencies(
			insomniac: insomniac,
			scheduleEvaluator: scheduleEvaluator,
			appRulesEvaluator: appRulesEvaluator,
			automationCoordinator: automationCoordinator,
			shortcutManager: NSEventGlobalShortcutManager(),
			launchAtLoginManager: SMAppServiceLaunchAtLoginManager(),
			accessibilityPermissionChecker: AXAccessibilityPermissionChecker(),
			availableApps: { NSWorkspaceAppInfoProvider.runningRegularApps() },
		)
	}
}
