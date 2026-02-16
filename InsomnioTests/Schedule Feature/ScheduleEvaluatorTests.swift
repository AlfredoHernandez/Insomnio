//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import Testing

@MainActor
@Suite("ScheduleEvaluator")
struct ScheduleEvaluatorTests {
	@Test("Init loads rules from store")
	func init_loadsRulesFromStore() {
		let (_, _, store) = makeSUT()

		#expect(store.receivedMessages == [.loadRules])
	}

	@Test("shouldBeActive with no rules returns false")
	func shouldBeActive_withNoRules_returnsFalse() {
		let (sut, _, _) = makeSUT()

		#expect(sut.shouldBeActive() == false)
	}

	@Test("shouldBeActive with matching weekday and time in range returns true")
	func shouldBeActive_withMatchingWeekdayAndTimeInRange_returnsTrue() {
		let (sut, dateProvider, _) = makeSUT()
		dateProvider.stubbedWeekday = .monday
		dateProvider.stubbedHour = 10
		dateProvider.stubbedMinute = 0
		sut.rules = [ScheduleRule(weekdays: [.monday], startHour: 9, endHour: 18)]

		#expect(sut.shouldBeActive() == true)
	}

	@Test("shouldBeActive with matching weekday and time out of range returns false")
	func shouldBeActive_withMatchingWeekdayAndTimeOutOfRange_returnsFalse() {
		let (sut, dateProvider, _) = makeSUT()
		dateProvider.stubbedWeekday = .monday
		dateProvider.stubbedHour = 19
		dateProvider.stubbedMinute = 0
		sut.rules = [ScheduleRule(weekdays: [.monday], startHour: 9, endHour: 18)]

		#expect(sut.shouldBeActive() == false)
	}

	@Test("shouldBeActive with non-matching weekday returns false")
	func shouldBeActive_withNonMatchingWeekday_returnsFalse() {
		let (sut, dateProvider, _) = makeSUT()
		dateProvider.stubbedWeekday = .tuesday
		dateProvider.stubbedHour = 10
		dateProvider.stubbedMinute = 0
		sut.rules = [ScheduleRule(weekdays: [.monday], startHour: 9, endHour: 18)]

		#expect(sut.shouldBeActive() == false)
	}

	@Test("shouldBeActive with disabled rule returns false")
	func shouldBeActive_withDisabledRule_returnsFalse() {
		let (sut, dateProvider, _) = makeSUT()
		dateProvider.stubbedWeekday = .monday
		dateProvider.stubbedHour = 10
		dateProvider.stubbedMinute = 0
		sut.rules = [ScheduleRule(weekdays: [.monday], startHour: 9, endHour: 18, isEnabled: false)]

		#expect(sut.shouldBeActive() == false)
	}

	@Test("shouldBeActive with overnight range before midnight returns true")
	func shouldBeActive_withOvernightRange_beforeMidnight_returnsTrue() {
		let (sut, dateProvider, _) = makeSUT()
		dateProvider.stubbedWeekday = .monday
		dateProvider.stubbedHour = 23
		dateProvider.stubbedMinute = 0
		sut.rules = [ScheduleRule(weekdays: [.monday], startHour: 22, endHour: 6)]

		#expect(sut.shouldBeActive() == true)
	}

	@Test("shouldBeActive with overnight range after midnight returns true")
	func shouldBeActive_withOvernightRange_afterMidnight_returnsTrue() {
		let (sut, dateProvider, _) = makeSUT()
		dateProvider.stubbedWeekday = .tuesday
		dateProvider.stubbedHour = 3
		dateProvider.stubbedMinute = 0
		sut.rules = [ScheduleRule(weekdays: [.monday], startHour: 22, endHour: 6)]

		#expect(sut.shouldBeActive() == true)
	}

	@Test("shouldBeActive with multiple rules any match returns true")
	func shouldBeActive_withMultipleRules_anyMatchReturnsTrue() {
		let (sut, dateProvider, _) = makeSUT()
		dateProvider.stubbedWeekday = .friday
		dateProvider.stubbedHour = 14
		dateProvider.stubbedMinute = 0
		sut.rules = [
			ScheduleRule(weekdays: [.monday], startHour: 9, endHour: 18),
			ScheduleRule(weekdays: [.friday], startHour: 12, endHour: 16),
		]

		#expect(sut.shouldBeActive() == true)
	}

	@Test("shouldBeActive at exact start time returns true")
	func shouldBeActive_atExactStartTime_returnsTrue() {
		let (sut, dateProvider, _) = makeSUT()
		dateProvider.stubbedWeekday = .monday
		dateProvider.stubbedHour = 9
		dateProvider.stubbedMinute = 0
		sut.rules = [ScheduleRule(weekdays: [.monday], startHour: 9, endHour: 18)]

		#expect(sut.shouldBeActive() == true)
	}

	@Test("shouldBeActive at exact end time returns false")
	func shouldBeActive_atExactEndTime_returnsFalse() {
		let (sut, dateProvider, _) = makeSUT()
		dateProvider.stubbedWeekday = .monday
		dateProvider.stubbedHour = 18
		dateProvider.stubbedMinute = 0
		sut.rules = [ScheduleRule(weekdays: [.monday], startHour: 9, endHour: 18)]

		#expect(sut.shouldBeActive() == false)
	}

	@Test("addRule appends and saves")
	func addRule_appendsAndSaves() {
		let (sut, _, store) = makeSUT()
		let rule = ScheduleRule(weekdays: [.monday])

		sut.addRule(rule)

		#expect(sut.rules.count == 1)
		#expect(store.receivedMessages == [.loadRules, .saveRules])
	}

	@Test("removeRule removes and saves")
	func removeRule_removesAndSaves() {
		let rule = ScheduleRule(weekdays: [.monday])
		let (sut, _, store) = makeSUT(initialRules: [rule])

		sut.removeRule(id: rule.id)

		#expect(sut.rules.isEmpty)
		#expect(store.receivedMessages == [.loadRules, .saveRules])
	}

	@Test("updateRule updates and saves")
	func updateRule_updatesAndSaves() {
		var rule = ScheduleRule(weekdays: [.monday], startHour: 9, endHour: 18)
		let (sut, _, store) = makeSUT(initialRules: [rule])

		rule.startHour = 8
		sut.updateRule(rule)

		#expect(sut.rules.first?.startHour == 8)
		#expect(store.receivedMessages == [.loadRules, .saveRules])
	}

	// MARK: - Helpers

	private func makeSUT(initialRules: [ScheduleRule] = [])
		-> (sut: ScheduleEvaluatorImpl, dateProvider: DateProviderSpy, store: RuleStoreSpy<ScheduleRule>)
	{
		let dateProvider = DateProviderSpy()
		let store = RuleStoreSpy<ScheduleRule>()
		store.stubbedRules = initialRules
		let sut = ScheduleEvaluatorImpl(dateProvider: dateProvider, store: store)
		return (sut, dateProvider, store)
	}
}
