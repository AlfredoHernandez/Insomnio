//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import Foundation
import Testing

@MainActor
@Suite("UserDefaultsPremiumStatusCache")
struct UserDefaultsPremiumStatusCacheTests {
	@Test("isPremium defaults to false when no value is stored")
	func isPremium_defaultsToFalseWhenNoValueIsStored() {
		let (sut, cleanup) = makeSUT()
		defer { cleanup() }

		#expect(sut.isPremium == false)
	}

	@Test("Setting isPremium to true persists the value")
	func isPremium_persistsTrueValue() {
		let (sut, cleanup) = makeSUT()
		defer { cleanup() }

		sut.isPremium = true

		#expect(sut.isPremium == true)
	}

	@Test("Setting isPremium back to false updates correctly")
	func isPremium_updatesBackToFalse() {
		let (sut, cleanup) = makeSUT()
		defer { cleanup() }

		sut.isPremium = true
		sut.isPremium = false

		#expect(sut.isPremium == false)
	}

	@Test("isPremium uses the correct key in UserDefaults")
	func isPremium_usesCorrectKeyInUserDefaults() throws {
		let suiteName = "test.premium.\(UUID().uuidString)"
		let defaults = try #require(UserDefaults(suiteName: suiteName))
		let key = "custom.premium.key"
		let sut = UserDefaultsPremiumStatusCache(defaults: defaults, key: key)
		defer { defaults.removePersistentDomain(forName: suiteName) }

		sut.isPremium = true

		#expect(defaults.bool(forKey: key) == true)
		#expect(defaults.bool(forKey: "io.alfredohdz.Insomnio.isPremium") == false)
	}

	// MARK: - Memory Leak Tracking

	@Test("makeSUT does not leak after read and write")
	func makeSUT_doesNotLeakAfterReadAndWrite() {
		assertNoLeaks {
			let suiteName = "test.premium.leak.\(UUID().uuidString)"
			let defaults = UserDefaults(suiteName: suiteName)!
			let sut = UserDefaultsPremiumStatusCache(defaults: defaults)
			sut.isPremium = true
			_ = sut.isPremium
			defaults.removePersistentDomain(forName: suiteName)
			return [sut]
		}
	}

	// MARK: - Helpers

	private func makeSUT() -> (sut: UserDefaultsPremiumStatusCache, cleanup: () -> Void) {
		let suiteName = "test.premium.\(UUID().uuidString)"
		let defaults = UserDefaults(suiteName: suiteName)!
		let sut = UserDefaultsPremiumStatusCache(defaults: defaults)
		return (sut, { defaults.removePersistentDomain(forName: suiteName) })
	}
}
