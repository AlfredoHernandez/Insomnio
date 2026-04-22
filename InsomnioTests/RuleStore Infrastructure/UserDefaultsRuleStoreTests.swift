//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import Foundation
import Testing

@MainActor
struct UserDefaultsRuleStoreTests {
	@Test
	func `Load returns empty array when no data stored`() {
		let (sut, cleanup) = makeSUT()
		defer { cleanup() }

		#expect(sut.loadRules() == [])
	}

	@Test
	func `Save and load round-trips rules`() {
		let (sut, cleanup) = makeSUT()
		defer { cleanup() }
		let rules = [
			ScheduleRule(weekdays: [.monday, .friday], startHour: 9, endHour: 18),
			ScheduleRule(weekdays: [.saturday], startHour: 10, startMinute: 30, endHour: 14),
		]

		sut.saveRules(rules)

		#expect(sut.loadRules() == rules)
	}

	@Test
	func `Save overwrites previous rules`() {
		let (sut, cleanup) = makeSUT()
		defer { cleanup() }
		let first = [ScheduleRule(weekdays: [.monday])]
		let second = [ScheduleRule(weekdays: [.tuesday, .wednesday])]

		sut.saveRules(first)
		sut.saveRules(second)

		#expect(sut.loadRules() == second)
	}

	@Test
	func `Save empty array clears rules`() {
		let (sut, cleanup) = makeSUT()
		defer { cleanup() }
		sut.saveRules([ScheduleRule(weekdays: [.monday])])

		sut.saveRules([])

		#expect(sut.loadRules() == [])
	}

	// MARK: - Memory Leak Tracking

	@Test
	func `makeSUT does not leak after save and load`() {
		assertNoLeaks {
			let suiteName = "test.rulestore.leak.\(UUID().uuidString)"
			let defaults = UserDefaults(suiteName: suiteName)!
			let sut = UserDefaultsRuleStore<ScheduleRule>(key: "testRules", defaults: defaults)
			sut.saveRules([ScheduleRule(weekdays: [.monday])])
			_ = sut.loadRules()
			defaults.removePersistentDomain(forName: suiteName)
			return [sut]
		}
	}

	// MARK: - Helpers

	private func makeSUT() -> (sut: UserDefaultsRuleStore<ScheduleRule>, cleanup: () -> Void) {
		let suiteName = "test.rulestore.\(UUID().uuidString)"
		let defaults = UserDefaults(suiteName: suiteName)!
		let sut = UserDefaultsRuleStore<ScheduleRule>(key: "testRules", defaults: defaults)
		return (sut, { defaults.removePersistentDomain(forName: suiteName) })
	}
}
