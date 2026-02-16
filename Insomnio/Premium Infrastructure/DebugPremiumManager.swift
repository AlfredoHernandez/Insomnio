//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

#if DEBUG

import Observation

@Observable
final class DebugPremiumManager: PremiumManager {
	var isPremium: Bool = true

	func loadProducts() async {}
	func purchase(_: PremiumProduct) async throws -> Bool {
		true
	}

	func restorePurchases() async {}
}

#endif
