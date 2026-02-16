//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio

@MainActor
final class PremiumManagerSpy: PremiumManager {
	enum ReceivedMessage: Equatable {
		case loadProducts
		case purchase(String)
		case restorePurchases
	}

	private(set) var receivedMessages = [ReceivedMessage]()
	var stubbedIsPremium = false
	var stubbedPurchaseResult = true

	var isPremium: Bool {
		stubbedIsPremium
	}

	func loadProducts() async {
		receivedMessages.append(.loadProducts)
	}

	func purchase(_ product: PremiumProduct) async throws -> Bool {
		receivedMessages.append(.purchase(product.rawValue))
		return stubbedPurchaseResult
	}

	func restorePurchases() async {
		receivedMessages.append(.restorePurchases)
	}
}
