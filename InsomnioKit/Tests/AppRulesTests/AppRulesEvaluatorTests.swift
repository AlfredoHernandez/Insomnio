//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppRules
import AppRulesTesting
import RuleStoreTesting
import Testing
import TestSupport

@MainActor
struct AppRulesEvaluatorTests {
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
	func `shouldBeActive with matching running app returns true`() {
		let (sut, provider, _) = makeSUT()
		sut.rules = [AppRule(bundleIdentifier: "com.example.app", displayName: "Example")]
		provider.stubbedRunningApps = ["com.example.app", "com.apple.finder"]

		#expect(sut.shouldBeActive() == true)
	}

	@Test
	func `shouldBeActive with non-matching running app returns false`() {
		let (sut, provider, _) = makeSUT()
		sut.rules = [AppRule(bundleIdentifier: "com.example.app", displayName: "Example")]
		provider.stubbedRunningApps = ["com.apple.finder"]

		#expect(sut.shouldBeActive() == false)
	}

	@Test
	func `shouldBeActive with disabled rule returns false`() {
		let (sut, provider, _) = makeSUT()
		sut.rules = [AppRule(bundleIdentifier: "com.example.app", displayName: "Example", isEnabled: false)]
		provider.stubbedRunningApps = ["com.example.app"]

		#expect(sut.shouldBeActive() == false)
	}

	@Test
	func `shouldBeActive with multiple rules any match returns true`() {
		let (sut, provider, _) = makeSUT()
		sut.rules = [
			AppRule(bundleIdentifier: "com.example.app1", displayName: "App1"),
			AppRule(bundleIdentifier: "com.example.app2", displayName: "App2"),
		]
		provider.stubbedRunningApps = ["com.example.app2"]

		#expect(sut.shouldBeActive() == true)
	}

	@Test
	func `shouldBeActive with multiple rules none match returns false`() {
		let (sut, provider, _) = makeSUT()
		sut.rules = [
			AppRule(bundleIdentifier: "com.example.app1", displayName: "App1"),
			AppRule(bundleIdentifier: "com.example.app2", displayName: "App2"),
		]
		provider.stubbedRunningApps = ["com.apple.finder"]

		#expect(sut.shouldBeActive() == false)
	}

	@Test
	func `addRule appends and saves`() {
		let (sut, _, store) = makeSUT()
		let rule = AppRule(bundleIdentifier: "com.example.app", displayName: "Example")

		sut.addRule(rule)

		#expect(sut.rules == [rule])
		#expect(store.receivedMessages == [.loadRules, .saveRules])
	}

	@Test
	func `removeRule removes and saves`() {
		let rule = AppRule(bundleIdentifier: "com.example.app", displayName: "Example")
		let (sut, _, store) = makeSUT(initialRules: [rule])

		sut.removeRule(id: rule.id)

		#expect(sut.rules.isEmpty)
		#expect(store.receivedMessages == [.loadRules, .saveRules])
	}

	@Test
	func `updateRule updates and saves`() {
		var rule = AppRule(bundleIdentifier: "com.example.app", displayName: "Example")
		let (sut, _, store) = makeSUT(initialRules: [rule])

		rule.isEnabled = false
		sut.updateRule(rule)

		#expect(sut.rules.first?.isEnabled == false)
		#expect(store.receivedMessages == [.loadRules, .saveRules])
	}

	// MARK: - Memory Leak Tracking

	@Test
	func `makeSUT does not leak after rule operations`() {
		assertNoLeaks {
			let (sut, provider, store) = makeSUT()
			sut.addRule(AppRule(bundleIdentifier: "com.test", displayName: "Test"))
			_ = sut.shouldBeActive()
			return [sut, provider, store]
		}
	}

	// MARK: - Helpers

	private func makeSUT(initialRules: [AppRule] = [])
		-> (sut: RunningAppRulesEvaluator, provider: RunningAppProviderSpy, store: RuleStoreSpy<AppRule>)
	{
		let provider = RunningAppProviderSpy()
		let store = RuleStoreSpy<AppRule>()
		store.stubbedRules = initialRules
		let sut = RunningAppRulesEvaluator(runningAppProvider: provider, store: store)
		return (sut, provider, store)
	}
}
