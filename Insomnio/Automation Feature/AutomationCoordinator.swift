//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

@MainActor
final class AutomationCoordinator {
	private let scheduleEvaluator: any ScheduleEvaluator
	private let appRulesEvaluator: any AppRulesEvaluator
	private let insomniac: Insomniac
	private let timerScheduler: any TimerScheduler
	private var timer: TimerCancellable?
	private var manualOverrideActive = false

	init(
		scheduleEvaluator: any ScheduleEvaluator,
		appRulesEvaluator: any AppRulesEvaluator,
		insomniac: Insomniac,
		timerScheduler: any TimerScheduler,
	) {
		self.scheduleEvaluator = scheduleEvaluator
		self.appRulesEvaluator = appRulesEvaluator
		self.insomniac = insomniac
		self.timerScheduler = timerScheduler
		insomniac.onToggle = { [weak self] in self?.notifyManualToggle() }
	}

	func startMonitoring() {
		timer?.invalidate()
		timer = timerScheduler.schedule(interval: 60, repeats: true) { [weak self] in
			self?.evaluate()
		}
		evaluate()
	}

	func stopMonitoring() {
		timer?.invalidate()
		timer = nil
	}

	func notifyManualToggle() {
		manualOverrideActive = true
	}

	func evaluate() {
		let scheduleSaysActive = scheduleEvaluator.shouldBeActive()
		let appRulesSayActive = appRulesEvaluator.shouldBeActive()
		let automationWantsActive = scheduleSaysActive || appRulesSayActive

		if manualOverrideActive {
			if automationWantsActive == insomniac.isActive {
				manualOverrideActive = false
			}
			return
		}

		if automationWantsActive, !insomniac.isActive {
			insomniac.start()
		} else if !automationWantsActive, insomniac.isActive {
			insomniac.stop()
		}
	}
}
