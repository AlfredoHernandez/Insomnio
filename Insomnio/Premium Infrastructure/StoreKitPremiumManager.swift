//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import StoreKit

@Observable
final class StoreKitPremiumManager: PremiumManager {
	private(set) var isPremium: Bool = false

	private var products: [Product] = []
	private var transactionListener: Task<Void, Never>?

	init() {
		transactionListener = listenForTransactions()
		Task { await checkEntitlements() }
	}

	func loadProducts() async {
		do {
			products = try await Product.products(for: PremiumProduct.allCases.map(\.rawValue))
		} catch {}
	}

	func purchase(_ product: PremiumProduct) async throws -> Bool {
		guard let storeProduct = products.first(where: { $0.id == product.rawValue }) else {
			return false
		}
		let result = try await storeProduct.purchase()
		switch result {
		case let .success(verification):
			let transaction = try checkVerified(verification)
			await transaction.finish()
			await checkEntitlements()
			return true

		case .userCancelled, .pending:
			return false

		@unknown default:
			return false
		}
	}

	func restorePurchases() async {
		try? await AppStore.sync()
		await checkEntitlements()
	}

	var priceForLifetime: String? {
		products.first { $0.id == PremiumProduct.lifetime.rawValue }?.displayPrice
	}

	// MARK: - Private

	private func listenForTransactions() -> Task<Void, Never> {
		Task.detached { [weak self] in
			for await result in Transaction.updates {
				if case let .verified(transaction) = result {
					await transaction.finish()
					await self?.checkEntitlements()
				}
			}
		}
	}

	private func checkEntitlements() async {
		for await result in Transaction.currentEntitlements {
			if let transaction = try? checkVerified(result),
			   PremiumProduct(rawValue: transaction.productID) != nil
			{
				isPremium = true
				return
			}
		}
		isPremium = false
	}

	private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
		switch result {
		case .unverified:
			throw StoreError.verificationFailed

		case let .verified(safe):
			return safe
		}
	}
}

private enum StoreError: Error {
	case verificationFailed
}
