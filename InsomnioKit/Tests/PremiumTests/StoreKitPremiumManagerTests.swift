//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Premium
import Testing
import TestSupport

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

	@Test
	func `makeSUT does not leak`() {
		assertNoLeaks {
			[StoreKitPremiumManager()]
		}
	}
}
