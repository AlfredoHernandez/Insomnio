//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppRules
import Foundation
import Insomniac
import OSLog
import Schedule
import TimerScheduler

public final class AutomationCoordinator: AutomationCoordinating {
	private let scheduleEvaluator: any ScheduleRuleEvaluating
	private let appRulesEvaluator: any AppRulesEvaluating
	private let insomniac: Insomniac
	private let timerScheduler: any TimerScheduler
	private var timer: TimerCancellable?
	private var manualOverrideActive = false
	private let logger = Logger(subsystem: "io.alfredohdz.Insomnio", category: "AutomationCoordinator")

	public init(
		scheduleEvaluator: any ScheduleRuleEvaluating,
		appRulesEvaluator: any AppRulesEvaluating,
		insomniac: Insomniac,
		timerScheduler: any TimerScheduler,
	) {
		self.scheduleEvaluator = scheduleEvaluator
		self.appRulesEvaluator = appRulesEvaluator
		self.insomniac = insomniac
		self.timerScheduler = timerScheduler
		insomniac.onToggle = { [weak self] in self?.notifyManualToggle() }
	}

	public func startMonitoring() {
		timer?.invalidate()
		timer = timerScheduler.schedule(interval: 60, repeats: true) { [weak self] in
			self?.evaluate()
		}
		evaluate()
	}

	public func stopMonitoring() {
		timer?.invalidate()
		timer = nil
	}

	/// - Important: internal for testing; not part of the public API.
	/// Called externally by `Insomniac.onToggle` and by the internal timer.
	func notifyManualToggle() {
		manualOverrideActive = true
	}

	/// - Important: internal for testing; not part of the public API.
	/// Called by the internal monitoring timer on each tick.
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
			logger.info("Automation activating Insomniac")
			insomniac.start()
		} else if !automationWantsActive, insomniac.isActive {
			logger.info("Automation deactivating Insomniac")
			insomniac.stop()
		}
	}
}
