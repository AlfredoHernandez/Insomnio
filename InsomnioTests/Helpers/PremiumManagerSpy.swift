//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import Observation
import Premium

@MainActor
@Observable
final class PremiumManagerSpy: PremiumManager {
	enum ReceivedMessage: Equatable {
		case refreshStatus
		case loadProducts
		case purchase(PremiumProduct)
		case restorePurchases
	}

	private(set) var receivedMessages = [ReceivedMessage]()
	var isPremium: Bool = false
	var lifetimeDisplayPrice: String?

	func refreshStatus() async {
		receivedMessages.append(.refreshStatus)
	}

	func loadProducts() async {
		receivedMessages.append(.loadProducts)
	}

	func purchase(_ product: PremiumProduct) async throws -> Bool {
		receivedMessages.append(.purchase(product))
		return false
	}

	func restorePurchases() async {
		receivedMessages.append(.restorePurchases)
	}
}
