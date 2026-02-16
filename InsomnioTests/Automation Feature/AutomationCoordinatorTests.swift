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
		let (sut, _, _, insomniac) = makeSUT()

		sut.evaluate()

		#expect(insomniac.isActive == false)
	}

	@Test("Evaluate with schedule active starts insomniac")
	func evaluate_scheduleActive_startsInsomniac() {
		let (sut, schedule, _, insomniac) = makeSUT()
		schedule.stubbedShouldBeActive = true

		sut.evaluate()

		#expect(insomniac.isActive == true)
	}

	@Test("Evaluate with app rule active starts insomniac")
	func evaluate_appRuleActive_startsInsomniac() {
		let (sut, _, appRules, insomniac) = makeSUT()
		appRules.stubbedShouldBeActive = true

		sut.evaluate()

		#expect(insomniac.isActive == true)
	}

	@Test("Evaluate with automation becoming inactive stops insomniac")
	func evaluate_automationBecomesInactive_stopsInsomniac() {
		let (sut, schedule, _, insomniac) = makeSUT()
		schedule.stubbedShouldBeActive = true
		sut.evaluate()
		#expect(insomniac.isActive == true)

		schedule.stubbedShouldBeActive = false
		sut.evaluate()

		#expect(insomniac.isActive == false)
	}

	@Test("Evaluate with manual override does not undo user action")
	func evaluate_manualOverride_doesNotUndoUserAction() {
		let (sut, schedule, _, insomniac) = makeSUT()
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
		let (sut, schedule, _, insomniac) = makeSUT()
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
		let (sut, schedule, appRules, insomniac) = makeSUT()
		schedule.stubbedShouldBeActive = true
		appRules.stubbedShouldBeActive = true

		sut.evaluate()

		#expect(insomniac.isActive == true)
	}

	@Test("Evaluate does not restart already active insomniac")
	func evaluate_doesNotRestartAlreadyActive() {
		let (sut, schedule, _, insomniac) = makeSUT()
		schedule.stubbedShouldBeActive = true

		sut.evaluate()
		let firstActivation = insomniac.activationCount

		sut.evaluate()

		#expect(insomniac.activationCount == firstActivation)
	}

	// MARK: - Helpers

	private func makeSUT()
		-> (
			sut: AutomationCoordinator,
			schedule: ScheduleEvaluatorSpy,
			appRules: AppRulesEvaluatorSpy,
			insomniac: Insomniac,
		)
	{
		let schedule = ScheduleEvaluatorSpy()
		let appRules = AppRulesEvaluatorSpy()
		let insomniac = Insomniac(
			mouseMover: MouseMoverSpy(),
			sleepPreventer: SleepPreventerSpy(),
		)
		let sut = AutomationCoordinator(
			scheduleEvaluator: schedule,
			appRulesEvaluator: appRules,
			insomniac: insomniac,
		)
		return (sut, schedule, appRules, insomniac)
	}
}
