//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import Testing

@MainActor
@Suite("AutomationCoordinator")
struct AutomationCoordinatorTests {
	@Test("Evaluate with no automation does not start")
	func evaluate_noAutomation_doesNotStart() {
		let (sut, _, _, insomniac, _) = makeSUT()

		sut.evaluate()

		#expect(insomniac.isActive == false)
	}

	@Test("Evaluate with schedule active starts insomniac")
	func evaluate_scheduleActive_startsInsomniac() {
		let (sut, schedule, _, insomniac, _) = makeSUT()
		schedule.stubbedShouldBeActive = true

		sut.evaluate()

		#expect(insomniac.isActive == true)
	}

	@Test("Evaluate with app rule active starts insomniac")
	func evaluate_appRuleActive_startsInsomniac() {
		let (sut, _, appRules, insomniac, _) = makeSUT()
		appRules.stubbedShouldBeActive = true

		sut.evaluate()

		#expect(insomniac.isActive == true)
	}

	@Test("Evaluate with automation becoming inactive stops insomniac")
	func evaluate_automationBecomesInactive_stopsInsomniac() {
		let (sut, schedule, _, insomniac, _) = makeSUT()
		schedule.stubbedShouldBeActive = true
		sut.evaluate()
		#expect(insomniac.isActive == true)

		schedule.stubbedShouldBeActive = false
		sut.evaluate()

		#expect(insomniac.isActive == false)
	}

	@Test("Evaluate with manual override does not undo user action")
	func evaluate_manualOverride_doesNotUndoUserAction() {
		let (sut, schedule, _, insomniac, _) = makeSUT()
		schedule.stubbedShouldBeActive = true
		sut.evaluate()
		#expect(insomniac.isActive == true)

		insomniac.stop()
		sut.notifyManualToggle()

		sut.evaluate()
		#expect(insomniac.isActive == false)
	}

	@Test("Evaluate clears manual override when automation agrees with state")
	func evaluate_manualOverrideClearsWhenAutomationAgreesWithState() {
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

	@Test("Evaluate with both active starts insomniac once")
	func evaluate_bothActive_startsInsomniac() {
		let (sut, schedule, appRules, insomniac, _) = makeSUT()
		schedule.stubbedShouldBeActive = true
		appRules.stubbedShouldBeActive = true

		sut.evaluate()

		#expect(insomniac.isActive == true)
	}

	@Test("Evaluate does not restart already active insomniac")
	func evaluate_doesNotRestartAlreadyActive() {
		let (sut, schedule, _, insomniac, _) = makeSUT()
		schedule.stubbedShouldBeActive = true

		sut.evaluate()
		let firstActivation = insomniac.activationCount

		sut.evaluate()

		#expect(insomniac.activationCount == firstActivation)
	}

	// MARK: - Timer Scheduler Tests

	@Test("Start monitoring schedules timer every 60 seconds")
	func startMonitoring_schedulesTimerEvery60Seconds() {
		let (sut, _, _, _, timerScheduler) = makeSUT()

		sut.startMonitoring()

		#expect(timerScheduler.receivedMessages == [.schedule(interval: 60)])
	}

	@Test("Start monitoring timer fire calls evaluate")
	func startMonitoring_timerFireCallsEvaluate() {
		let (sut, schedule, _, insomniac, timerScheduler) = makeSUT()
		schedule.stubbedShouldBeActive = true

		sut.startMonitoring()
		#expect(insomniac.isActive == true)

		insomniac.stop()
		timerScheduler.fire(at: 0)

		#expect(insomniac.isActive == true)
	}

	@Test("Stop monitoring invalidates timer")
	func stopMonitoring_invalidatesTimer() {
		let (sut, _, _, _, timerScheduler) = makeSUT()

		sut.startMonitoring()
		sut.stopMonitoring()

		#expect(timerScheduler.receivedMessages.contains(.invalidate))
	}

	// MARK: - Memory Leak Tracking

	@Test("makeSUT does not leak after evaluate cycle")
	func makeSUT_doesNotLeakAfterEvaluateCycle() {
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
		schedule: ScheduleEvaluatorStub,
		appRules: AppRulesEvaluatorStub,
		insomniac: Insomniac,
		timerScheduler: TimerSchedulerSpy,
	) {
		let schedule = ScheduleEvaluatorStub()
		let appRules = AppRulesEvaluatorStub()
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
