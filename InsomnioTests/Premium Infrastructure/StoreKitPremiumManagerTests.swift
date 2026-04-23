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

	@Test
	func `makeSUT does not leak`() {
		assertNoLeaks {
			[StoreKitPremiumManager()]
		}
	}
}
