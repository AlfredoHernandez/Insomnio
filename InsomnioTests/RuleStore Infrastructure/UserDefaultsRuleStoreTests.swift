//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import Foundation
import Testing

@MainActor
@Suite("UserDefaultsRuleStore")
struct UserDefaultsRuleStoreTests {
	@Test("Load returns empty array when no data stored")
	func load_returnsEmptyArrayWhenNoDataStored() {
		let (sut, cleanup) = makeSUT()
		defer { cleanup() }

		#expect(sut.loadRules() == [])
	}

	@Test("Save and load round-trips rules")
	func saveAndLoad_roundTripsRules() {
		let (sut, cleanup) = makeSUT()
		defer { cleanup() }
		let rules = [
			ScheduleRule(weekdays: [.monday, .friday], startHour: 9, endHour: 18),
			ScheduleRule(weekdays: [.saturday], startHour: 10, startMinute: 30, endHour: 14),
		]

		sut.saveRules(rules)

		#expect(sut.loadRules() == rules)
	}

	@Test("Save overwrites previous rules")
	func save_overwritesPreviousRules() {
		let (sut, cleanup) = makeSUT()
		defer { cleanup() }
		let first = [ScheduleRule(weekdays: [.monday])]
		let second = [ScheduleRule(weekdays: [.tuesday, .wednesday])]

		sut.saveRules(first)
		sut.saveRules(second)

		#expect(sut.loadRules() == second)
	}

	@Test("Save empty array clears rules")
	func save_emptyArrayClearsRules() {
		let (sut, cleanup) = makeSUT()
		defer { cleanup() }
		sut.saveRules([ScheduleRule(weekdays: [.monday])])

		sut.saveRules([])

		#expect(sut.loadRules() == [])
	}

	// MARK: - Helpers

	private func makeSUT() -> (sut: UserDefaultsRuleStore<ScheduleRule>, cleanup: () -> Void) {
		let suiteName = "test.rulestore.\(UUID().uuidString)"
		let defaults = UserDefaults(suiteName: suiteName)!
		let sut = UserDefaultsRuleStore<ScheduleRule>(key: "testRules", defaults: defaults)
		return (sut, { defaults.removePersistentDomain(forName: suiteName) })
	}
}
