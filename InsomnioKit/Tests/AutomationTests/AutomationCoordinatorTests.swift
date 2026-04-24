//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppRulesTesting
@_spi(Testing) import Automation
import Insomniac
import InsomniacTesting
import ScheduleTesting
import Testing
import TestSupport
import TimerSchedulerTesting

struct AutomationCoordinatorTests {
	@Test
	func `Evaluate with no automation does not start`() {
		let (sut, _, _, insomniac, _) = makeSUT()

		sut.evaluate()

		#expect(insomniac.isActive == false)
	}

	@Test
	func `Evaluate with schedule active starts insomniac`() {
		let (sut, schedule, _, insomniac, _) = makeSUT()
		schedule.stubbedShouldBeActive = true

		sut.evaluate()

		#expect(insomniac.isActive == true)
	}

	@Test
	func `Evaluate with app rule active starts insomniac`() {
		let (sut, _, appRules, insomniac, _) = makeSUT()
		appRules.stubbedShouldBeActive = true

		sut.evaluate()

		#expect(insomniac.isActive == true)
	}

	@Test
	func `Evaluate with automation becoming inactive stops insomniac`() {
		let (sut, schedule, _, insomniac, _) = makeSUT()
		schedule.stubbedShouldBeActive = true
		sut.evaluate()
		#expect(insomniac.isActive == true)

		schedule.stubbedShouldBeActive = false
		sut.evaluate()

		#expect(insomniac.isActive == false)
	}

	@Test
	func `Evaluate with manual override does not undo user action`() {
		let (sut, schedule, _, insomniac, _) = makeSUT()
		schedule.stubbedShouldBeActive = true
		sut.evaluate()
		#expect(insomniac.isActive == true)

		insomniac.stop()
		sut.notifyManualToggle()

		sut.evaluate()
		#expect(insomniac.isActive == false)
	}

	@Test
	func `Evaluate clears manual override when automation agrees with state`() {
		let (sut, schedule, _, insomniac, _) = makeSUT()
		schedule.stubbedShouldBeActive = true
		sut.evaluate()
		insomniac.stop()
		sut.notifyManualToggle()

		schedule.stubbedShouldBeActive = false
		sut.evaluate()

		schedule.stubbedShouldBeActive = true
		sut.evaluate()
		#expect(insomniac.isActive == true)
	}

	@Test
	func `Evaluate with both active starts insomniac once`() {
		let (sut, schedule, appRules, insomniac, _) = makeSUT()
		schedule.stubbedShouldBeActive = true
		appRules.stubbedShouldBeActive = true

		sut.evaluate()

		#expect(insomniac.isActive == true)
	}

	@Test
	func `Evaluate does not restart already active insomniac`() {
		let (sut, schedule, _, insomniac, _) = makeSUT()
		schedule.stubbedShouldBeActive = true

		sut.evaluate()
		let firstActivation = insomniac.activationCount

		sut.evaluate()

		#expect(insomniac.activationCount == firstActivation)
	}

	// MARK: - Timer Scheduler Tests

	@Test
	func `Start monitoring schedules timer every 60 seconds`() {
		let (sut, _, _, _, timerScheduler) = makeSUT()

		sut.startMonitoring()

		#expect(timerScheduler.receivedMessages == [.schedule(interval: 60)])
	}

	@Test
	func `Start monitoring timer fire calls evaluate`() {
		let (sut, schedule, _, insomniac, timerScheduler) = makeSUT()
		schedule.stubbedShouldBeActive = true

		sut.startMonitoring()
		#expect(insomniac.isActive == true)

		insomniac.stop()
		timerScheduler.fire(at: 0)

		#expect(insomniac.isActive == true)
	}

	@Test
	func `Stop monitoring invalidates timer`() {
		let (sut, _, _, _, timerScheduler) = makeSUT()

		sut.startMonitoring()
		sut.stopMonitoring()

		#expect(timerScheduler.receivedMessages.contains(.invalidate))
	}

	// MARK: - Memory Leak Tracking

	@Test
	func `makeSUT does not leak after evaluate cycle`() {
		assertNoLeaks {
			let (sut, schedule, appRules, insomniac, timerScheduler) = makeSUT()
			schedule.stubbedShouldBeActive = true
			sut.evaluate()
			sut.startMonitoring()
			sut.stopMonitoring()
			return [sut, schedule, appRules, insomniac, timerScheduler]
		}
	}

	// MARK: - Helpers

	private func makeSUT() -> (
		sut: AutomationCoordinator,
		schedule: ScheduleEvaluatorSpy,
		appRules: AppRulesEvaluatorSpy,
		insomniac: Insomniac,
		timerScheduler: TimerSchedulerSpy,
	) {
		let schedule = ScheduleEvaluatorSpy()
		let appRules = AppRulesEvaluatorSpy()
		let insomniac = Insomniac(
			mouseMover: MouseMoverSpy(),
			sleepPreventer: SleepPreventerSpy(),
			timerScheduler: TimerSchedulerSpy(),
		)
		let timerScheduler = TimerSchedulerSpy()
		let sut = AutomationCoordinator(
			scheduleEvaluator: schedule,
			appRulesEvaluator: appRules,
			insomniac: insomniac,
			timerScheduler: timerScheduler,
		)
		return (sut, schedule, appRules, insomniac, timerScheduler)
	}
}
