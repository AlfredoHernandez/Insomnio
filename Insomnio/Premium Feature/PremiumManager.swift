//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Observation

protocol PremiumManager: AnyObject, Observable {
	var isPremium: Bool { get }
	var lifetimeDisplayPrice: String? { get }
	func refreshStatus() async
	func loadProducts() async
	func purchase(_ product: PremiumProduct) async throws -> Bool
	func restorePurchases() async
}
