//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

@main
struct InsomnioApp: App {
	@State private var autoStopTimer = FoundationAutoStopTimer()
	@State private var premiumManager: any PremiumManager = {
		#if DEBUG
		DebugPremiumManager()
		#else
		StoreKitPremiumManager()
		#endif
	}()

	private let shortcutManager = NSEventGlobalShortcutManager()

	@State private var insomniac: Insomniac
	@State private var scheduleEvaluator: ScheduleEvaluatorImpl
	@State private var appRulesEvaluator: AppRulesEvaluatorImpl
	@State private var automationCoordinator: AutomationCoordinator

	init() {
		let autoStop = FoundationAutoStopTimer()
		let insomniac = Insomniac(
			mouseMover: CGMouseMover(),
			sleepPreventer: IOKitSleepPreventer(),
			idleTimeProvider: CGIdleTimeProvider(),
			powerSourceProvider: IOKitPowerSourceProvider(),
			autoStopTimer: autoStop,
		)
		let schedule = ScheduleEvaluatorImpl(
			dateProvider: FoundationDateProvider(),
			store: UserDefaultsScheduleStore(),
		)
		let appRules = AppRulesEvaluatorImpl(
			runningAppProvider: NSWorkspaceRunningAppProvider(),
			store: UserDefaultsAppRulesStore(),
		)

		_autoStopTimer = State(initialValue: autoStop)
		_insomniac = State(initialValue: insomniac)
		_scheduleEvaluator = State(initialValue: schedule)
		_appRulesEvaluator = State(initialValue: appRules)
		_automationCoordinator = State(initialValue: AutomationCoordinator(
			scheduleEvaluator: schedule,
			appRulesEvaluator: appRules,
			insomniac: insomniac,
		))
	}

	var body: some Scene {
		Window("Insomnio", id: "main") {
			InsomnioView(
				insomniac: insomniac,
				premiumManager: premiumManager,
				scheduleEvaluator: scheduleEvaluator,
				appRulesEvaluator: appRulesEvaluator,
				onManualToggle: { automationCoordinator.notifyManualToggle() },
			)
			.onAppear {
				shortcutManager.registerShortcut { [insomniac] in
					insomniac.toggle()
					automationCoordinator.notifyManualToggle()
				}
				automationCoordinator.startMonitoring()
				Task {
					await premiumManager.loadProducts()
				}
			}
		}
		.defaultSize(width: 420, height: 560)
		.windowResizability(.contentSize)

		MenuBarExtra("Insomnio", systemImage: insomniac.isActive ? "moon.zzz.fill" : "moon.zzz") {
			MenuBarView(insomniac: insomniac)
		}
	}
}
