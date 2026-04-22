//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Observation

/// Refines `Observable` so SwiftUI views can observe `isPremium` changes
/// through the existential `any PremiumManager`. `Observation` is a pure-Swift,
/// UI-agnostic framework; the dependency does not couple this feature layer
/// to AppKit/SwiftUI.
protocol PremiumManager: AnyObject, Observable {
	var isPremium: Bool { get }
	var lifetimeDisplayPrice: String? { get }
	func refreshStatus() async
	func loadProducts() async
	func purchase(_ product: PremiumProduct) async throws -> Bool
	func restorePurchases() async
}
