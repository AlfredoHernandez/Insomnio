//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import RuleStore
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
		let rules = [TestRule(id: 1, name: "first"), TestRule(id: 2, name: "second")]

		sut.saveRules(rules)

		#expect(sut.loadRules() == rules)
	}

	@Test
	func `Save overwrites previous rules`() {
		let (sut, cleanup) = makeSUT()
		defer { cleanup() }
		let first = [TestRule(id: 1, name: "a")]
		let second = [TestRule(id: 2, name: "b"), TestRule(id: 3, name: "c")]

		sut.saveRules(first)
		sut.saveRules(second)

		#expect(sut.loadRules() == second)
	}

	@Test
	func `Save empty array clears rules`() {
		let (sut, cleanup) = makeSUT()
		defer { cleanup() }
		sut.saveRules([TestRule(id: 1, name: "a")])

		sut.saveRules([])

		#expect(sut.loadRules() == [])
	}

	@Test
	func `makeSUT does not leak after save and load`() {
		assertNoLeaks {
			let suiteName = "test.rulestore.leak.\(UUID().uuidString)"
			let defaults = UserDefaults(suiteName: suiteName)!
			let sut = UserDefaultsRuleStore<TestRule>(key: "testRules", defaults: defaults)
			sut.saveRules([TestRule(id: 1, name: "a")])
			_ = sut.loadRules()
			defaults.removePersistentDomain(forName: suiteName)
			return [sut]
		}
	}

	// MARK: - Helpers

	private struct TestRule: Codable, Equatable {
		let id: Int
		let name: String
	}

	private func makeSUT() -> (sut: UserDefaultsRuleStore<TestRule>, cleanup: () -> Void) {
		let suiteName = "test.rulestore.\(UUID().uuidString)"
		let defaults = UserDefaults(suiteName: suiteName)!
		let sut = UserDefaultsRuleStore<TestRule>(key: "testRules", defaults: defaults)
		return (sut, { defaults.removePersistentDomain(forName: suiteName) })
	}
}

@MainActor
private func assertNoLeaks(
	sourceLocation: SourceLocation = #_sourceLocation,
	_ body: @MainActor () -> [AnyObject],
) {
	var weakRefs: [() -> AnyObject?] = []
	autoreleasepool {
		let instances = body()
		weakRefs = instances.map { instance in
			{ [weak instance] in instance }
		}
	}
	for ref in weakRefs {
		#expect(ref() == nil, "Instance should have been deallocated. Potential memory leak!", sourceLocation: sourceLocation)
	}
}
