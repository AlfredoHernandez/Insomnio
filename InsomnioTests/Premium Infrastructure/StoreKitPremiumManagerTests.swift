//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import Premium
import Testing

@MainActor
struct StoreKitPremiumManagerTests {
	@Test
	func `Initial isPremium is false before any entitlement resolves`() {
		let sut = StoreKitPremiumManager()

		#expect(sut.isPremium == false)
	}

	@Test
	func `Initial lifetimeDisplayPrice is nil before products load`() {
		let sut = StoreKitPremiumManager()

		#expect(sut.lifetimeDisplayPrice == nil)
	}

	// Memory-leak tracking is intentionally omitted here. `StoreKitPremiumManager`
	// kicks off both a non-detached `Task { await checkEntitlements() }` and a
	// detached `Transaction.updates` listener in `init`. The inner `Task`
	// captures `self` strongly for the duration of the initial entitlement
	// check, so a synchronous `assertNoLeaks` check racing right after `init`
	// flags a false positive. The task completes and the deinit cancels the
	// listener under normal app lifetime.
}
