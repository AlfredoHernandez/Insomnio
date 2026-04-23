//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import Schedule
import Testing

@MainActor
struct ScheduleEvaluatorTests {
	@Test
	func `Init loads rules from store`() {
		let (_, _, store) = makeSUT()

		#expect(store.receivedMessages == [.loadRules])
	}

	@Test
	func `shouldBeActive with no rules returns false`() {
		let (sut, _, _) = makeSUT()

		#expect(sut.shouldBeActive() == false)
	}

	@Test
	func `shouldBeActive with matching weekday and time in range returns true`() {
		let (sut, dateProvider, _) = makeSUT()
		dateProvider.stubbedWeekday = .monday
		dateProvider.stubbedHour = 10
		dateProvider.stubbedMinute = 0
		sut.rules = [ScheduleRule(weekdays: [.monday], startHour: 9, endHour: 18)]

		#expect(sut.shouldBeActive() == true)
	}

	@Test
	func `shouldBeActive with matching weekday and time out of range returns false`() {
		let (sut, dateProvider, _) = makeSUT()
		dateProvider.stubbedWeekday = .monday
		dateProvider.stubbedHour = 19
		dateProvider.stubbedMinute = 0
		sut.rules = [ScheduleRule(weekdays: [.monday], startHour: 9, endHour: 18)]

		#expect(sut.shouldBeActive() == false)
	}

	@Test
	func `shouldBeActive with non-matching weekday returns false`() {
		let (sut, dateProvider, _) = makeSUT()
		dateProvider.stubbedWeekday = .tuesday
		dateProvider.stubbedHour = 10
		dateProvider.stubbedMinute = 0
		sut.rules = [ScheduleRule(weekdays: [.monday], startHour: 9, endHour: 18)]

		#expect(sut.shouldBeActive() == false)
	}

	@Test
	func `shouldBeActive with disabled rule returns false`() {
		let (sut, dateProvider, _) = makeSUT()
		dateProvider.stubbedWeekday = .monday
		dateProvider.stubbedHour = 10
		dateProvider.stubbedMinute = 0
		sut.rules = [ScheduleRule(weekdays: [.monday], startHour: 9, endHour: 18, isEnabled: false)]

		#expect(sut.shouldBeActive() == false)
	}

	@Test
	func `shouldBeActive with overnight range before midnight returns true`() {
		let (sut, dateProvider, _) = makeSUT()
		dateProvider.stubbedWeekday = .monday
		dateProvider.stubbedHour = 23
		dateProvider.stubbedMinute = 0
		sut.rules = [ScheduleRule(weekdays: [.monday], startHour: 22, endHour: 6)]

		#expect(sut.shouldBeActive() == true)
	}

	@Test
	func `shouldBeActive with overnight range after midnight returns true`() {
		let (sut, dateProvider, _) = makeSUT()
		dateProvider.stubbedWeekday = .tuesday
		dateProvider.stubbedHour = 3
		dateProvider.stubbedMinute = 0
		sut.rules = [ScheduleRule(weekdays: [.monday], startHour: 22, endHour: 6)]

		#expect(sut.shouldBeActive() == true)
	}

	@Test
	func `shouldBeActive with multiple rules any match returns true`() {
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

	@Test
	func `shouldBeActive at exact start time returns true`() {
		let (sut, dateProvider, _) = makeSUT()
		dateProvider.stubbedWeekday = .monday
		dateProvider.stubbedHour = 9
		dateProvider.stubbedMinute = 0
		sut.rules = [ScheduleRule(weekdays: [.monday], startHour: 9, endHour: 18)]

		#expect(sut.shouldBeActive() == true)
	}

	@Test
	func `shouldBeActive at exact end time returns false`() {
		let (sut, dateProvider, _) = makeSUT()
		dateProvider.stubbedWeekday = .monday
		dateProvider.stubbedHour = 18
		dateProvider.stubbedMinute = 0
		sut.rules = [ScheduleRule(weekdays: [.monday], startHour: 9, endHour: 18)]

		#expect(sut.shouldBeActive() == false)
	}

	@Test
	func `addRule appends and saves`() {
		let (sut, _, store) = makeSUT()
		let rule = ScheduleRule(weekdays: [.monday])

		sut.addRule(rule)

		#expect(sut.rules.count == 1)
		#expect(store.receivedMessages == [.loadRules, .saveRules])
	}

	@Test
	func `removeRule removes and saves`() {
		let rule = ScheduleRule(weekdays: [.monday])
		let (sut, _, store) = makeSUT(initialRules: [rule])

		sut.removeRule(id: rule.id)

		#expect(sut.rules.isEmpty)
		#expect(store.receivedMessages == [.loadRules, .saveRules])
	}

	@Test
	func `updateRule updates and saves`() {
		var rule = ScheduleRule(weekdays: [.monday], startHour: 9, endHour: 18)
		let (sut, _, store) = makeSUT(initialRules: [rule])

		rule.startHour = 8
		sut.updateRule(rule)

		#expect(sut.rules.first?.startHour == 8)
		#expect(store.receivedMessages == [.loadRules, .saveRules])
	}

	// MARK: - Memory Leak Tracking

	@Test
	func `makeSUT does not leak after rule operations`() {
		assertNoLeaks {
			let (sut, dateProvider, store) = makeSUT()
			sut.addRule(ScheduleRule(weekdays: [.monday]))
			_ = sut.shouldBeActive()
			return [sut, dateProvider, store]
		}
	}

	// MARK: - Helpers

	private func makeSUT(initialRules: [ScheduleRule] = [])
		-> (sut: RuleBasedScheduleEvaluator, dateProvider: DateProviderSpy, store: RuleStoreSpy<ScheduleRule>)
	{
		let dateProvider = DateProviderSpy()
		let store = RuleStoreSpy<ScheduleRule>()
		store.stubbedRules = initialRules
		let sut = RuleBasedScheduleEvaluator(dateProvider: dateProvider, store: store)
		return (sut, dateProvider, store)
	}
}
