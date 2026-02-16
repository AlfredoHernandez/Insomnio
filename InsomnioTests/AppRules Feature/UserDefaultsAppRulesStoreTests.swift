//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import Foundation
import Testing

@MainActor
@Suite("UserDefaultsAppRulesStore")
struct UserDefaultsAppRulesStoreTests {
	@Test("Load returns empty array when no data stored")
	func load_returnsEmptyArrayWhenNoDataStored() {
		let sut = makeSUT()

		#expect(sut.loadRules() == [])
	}

	@Test("Save and load round-trips rules")
	func saveAndLoad_roundTripsRules() {
		let sut = makeSUT()
		let rules = [
			AppRule(bundleIdentifier: "com.example.app", displayName: "Example"),
			AppRule(bundleIdentifier: "com.apple.safari", displayName: "Safari", isEnabled: false),
		]

		sut.saveRules(rules)

		#expect(sut.loadRules() == rules)
	}

	@Test("Save overwrites previous rules")
	func save_overwritesPreviousRules() {
		let sut = makeSUT()
		let first = [AppRule(bundleIdentifier: "com.first.app", displayName: "First")]
		let second = [AppRule(bundleIdentifier: "com.second.app", displayName: "Second")]

		sut.saveRules(first)
		sut.saveRules(second)

		#expect(sut.loadRules() == second)
	}

	@Test("Save empty array clears rules")
	func save_emptyArrayClearsRules() {
		let sut = makeSUT()
		sut.saveRules([AppRule(bundleIdentifier: "com.example.app", displayName: "Example")])

		sut.saveRules([])

		#expect(sut.loadRules() == [])
	}

	// MARK: - Helpers

	private func makeSUT() -> UserDefaultsAppRulesStore {
		let defaults = UserDefaults(suiteName: "test.apprules.\(UUID().uuidString)")!
		return UserDefaultsAppRulesStore(defaults: defaults)
	}
}
