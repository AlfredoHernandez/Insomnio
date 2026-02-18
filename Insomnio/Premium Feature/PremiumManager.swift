//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

protocol PremiumManager: AnyObject {
	var isPremium: Bool { get }
	var lifetimeDisplayPrice: String? { get }
	func loadProducts() async
	func purchase(_ product: PremiumProduct) async throws -> Bool
	func restorePurchases() async
}
