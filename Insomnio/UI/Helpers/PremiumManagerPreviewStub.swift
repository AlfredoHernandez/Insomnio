//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

#if DEBUG
import Observation
import Premium

@Observable
final class PremiumManagerPreviewStub: PremiumManager {
	var isPremium = false
	var lifetimeDisplayPrice: String? = "$39.99"
	func refreshStatus() async {}
	func loadProducts() async {}
	func purchase(_: PremiumProduct) async throws -> Bool {
		true
	}

	func restorePurchases() async {}
}
#endif
