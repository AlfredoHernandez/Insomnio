//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

#if DEBUG

import Observation

@Observable
final class DebugPremiumManager: PremiumManager {
	var isPremium: Bool = true
	var lifetimeDisplayPrice: String? = "$39.99"

	func loadProducts() async {}
	func purchase(_: PremiumProduct) async throws -> Bool {
		true
	}

	func restorePurchases() async {}
}

#endif
