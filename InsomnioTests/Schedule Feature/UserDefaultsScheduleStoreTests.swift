//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import Foundation
import Testing

@MainActor
@Suite("UserDefaultsScheduleStore")
struct UserDefaultsScheduleStoreTests {
	@Test("Load returns empty array when no data stored")
	func load_returnsEmptyArrayWhenNoDataStored() {
		let sut = makeSUT()

		#expect(sut.loadRules() == [])
	}

	@Test("Save and load round-trips rules")
	func saveAndLoad_roundTripsRules() {
		let sut = makeSUT()
		let rules = [
			ScheduleRule(weekdays: [.monday, .friday], startHour: 9, endHour: 18),
			ScheduleRule(weekdays: [.saturday], startHour: 10, startMinute: 30, endHour: 14),
		]

		sut.saveRules(rules)

		#expect(sut.loadRules() == rules)
	}

	@Test("Save overwrites previous rules")
	func save_overwritesPreviousRules() {
		let sut = makeSUT()
		let first = [ScheduleRule(weekdays: [.monday])]
		let second = [ScheduleRule(weekdays: [.tuesday, .wednesday])]

		sut.saveRules(first)
		sut.saveRules(second)

		#expect(sut.loadRules() == second)
	}

	@Test("Save empty array clears rules")
	func save_emptyArrayClearsRules() {
		let sut = makeSUT()
		sut.saveRules([ScheduleRule(weekdays: [.monday])])

		sut.saveRules([])

		#expect(sut.loadRules() == [])
	}

	// MARK: - Helpers

	private func makeSUT() -> UserDefaultsScheduleStore {
		let defaults = UserDefaults(suiteName: "test.schedule.\(UUID().uuidString)")!
		return UserDefaultsScheduleStore(defaults: defaults)
	}
}
