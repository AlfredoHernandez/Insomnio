//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import Testing

@MainActor
@Suite("AppRulesEvaluator")
struct AppRulesEvaluatorTests {
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

	@Test("shouldBeActive with matching running app returns true")
	func shouldBeActive_withMatchingRunningApp_returnsTrue() {
		let (sut, provider, _) = makeSUT()
		sut.rules = [AppRule(bundleIdentifier: "com.example.app", displayName: "Example")]
		provider.stubbedRunningApps = ["com.example.app", "com.apple.finder"]

		#expect(sut.shouldBeActive() == true)
	}

	@Test("shouldBeActive with non-matching running app returns false")
	func shouldBeActive_withNonMatchingRunningApp_returnsFalse() {
		let (sut, provider, _) = makeSUT()
		sut.rules = [AppRule(bundleIdentifier: "com.example.app", displayName: "Example")]
		provider.stubbedRunningApps = ["com.apple.finder"]

		#expect(sut.shouldBeActive() == false)
	}

	@Test("shouldBeActive with disabled rule returns false")
	func shouldBeActive_withDisabledRule_returnsFalse() {
		let (sut, provider, _) = makeSUT()
		sut.rules = [AppRule(bundleIdentifier: "com.example.app", displayName: "Example", isEnabled: false)]
		provider.stubbedRunningApps = ["com.example.app"]

		#expect(sut.shouldBeActive() == false)
	}

	@Test("shouldBeActive with multiple rules any match returns true")
	func shouldBeActive_withMultipleRules_anyMatchReturnsTrue() {
		let (sut, provider, _) = makeSUT()
		sut.rules = [
			AppRule(bundleIdentifier: "com.example.app1", displayName: "App1"),
			AppRule(bundleIdentifier: "com.example.app2", displayName: "App2"),
		]
		provider.stubbedRunningApps = ["com.example.app2"]

		#expect(sut.shouldBeActive() == true)
	}

	@Test("shouldBeActive with multiple rules none match returns false")
	func shouldBeActive_withMultipleRules_noneMatchReturnsFalse() {
		let (sut, provider, _) = makeSUT()
		sut.rules = [
			AppRule(bundleIdentifier: "com.example.app1", displayName: "App1"),
			AppRule(bundleIdentifier: "com.example.app2", displayName: "App2"),
		]
		provider.stubbedRunningApps = ["com.apple.finder"]

		#expect(sut.shouldBeActive() == false)
	}

	@Test("addRule appends and saves")
	func addRule_appendsAndSaves() {
		let (sut, _, store) = makeSUT()
		let rule = AppRule(bundleIdentifier: "com.example.app", displayName: "Example")

		sut.addRule(rule)

		#expect(sut.rules.count == 1)
		#expect(store.receivedMessages == [.loadRules, .saveRules])
	}

	@Test("removeRule removes and saves")
	func removeRule_removesAndSaves() {
		let rule = AppRule(bundleIdentifier: "com.example.app", displayName: "Example")
		let (sut, _, store) = makeSUT(initialRules: [rule])

		sut.removeRule(id: rule.id)

		#expect(sut.rules.isEmpty)
		#expect(store.receivedMessages == [.loadRules, .saveRules])
	}

	@Test("updateRule updates and saves")
	func updateRule_updatesAndSaves() {
		var rule = AppRule(bundleIdentifier: "com.example.app", displayName: "Example")
		let (sut, _, store) = makeSUT(initialRules: [rule])

		rule.isEnabled = false
		sut.updateRule(rule)

		#expect(sut.rules.first?.isEnabled == false)
		#expect(store.receivedMessages == [.loadRules, .saveRules])
	}

	// MARK: - Helpers

	private func makeSUT(initialRules: [AppRule] = [])
		-> (sut: AppRulesEvaluatorImpl, provider: RunningAppProviderSpy, store: AppRulesStoreSpy)
	{
		let provider = RunningAppProviderSpy()
		let store = AppRulesStoreSpy()
		store.stubbedRules = initialRules
		let sut = AppRulesEvaluatorImpl(runningAppProvider: provider, store: store)
		return (sut, provider, store)
	}
}
