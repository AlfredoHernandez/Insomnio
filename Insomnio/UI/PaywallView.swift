//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import StoreKit
import SwiftUI

struct PaywallView: View {
	let premiumManager: any PremiumManager
	@Environment(\.dismiss) private var dismiss
	@State private var isPurchasing = false
	@State private var purchaseError: String?

	var body: some View {
		ScrollView {
			VStack(spacing: 0) {
				subscriptionSection

				lifetimeSection
			}
		}
		.frame(width: 380)
		.fixedSize(horizontal: false, vertical: true)
		.alert(
			"premium_purchase_error_title",
			isPresented: Binding(
				get: { purchaseError != nil },
				set: { if !$0 { purchaseError = nil } },
			),
			presenting: purchaseError,
		) { _ in
			Button("ok") { purchaseError = nil }
		} message: { message in
			Text(message)
		}
	}

	private var subscriptionSection: some View {
		SubscriptionStoreView(groupID: PremiumProduct.subscriptionGroupID) {
			VStack(spacing: 16) {
				Image(systemName: "star.circle.fill")
					.font(.system(size: 48))
					.foregroundStyle(.yellow)

				Text("premium_unlock_title")
					.font(.title2.bold())

				Text("premium_unlock_desc")
					.font(.subheadline)
					.foregroundStyle(.secondary)
					.multilineTextAlignment(.center)

				VStack(alignment: .leading, spacing: 8) {
					featureRow("clock.badge.checkmark", "premium_feature_autostop")
					featureRow("calendar.badge.clock", "premium_feature_schedule")
					featureRow("app.badge", "premium_feature_apprules")
					featureRow("cursorarrow.motionlines", "premium_feature_patterns")
				}
				.padding(.vertical, 8)
			}
			.padding(.horizontal, 20)
		}
		.onInAppPurchaseCompletion { _, result in
			if case .success(.success) = result {
				dismissAfterPurchase()
			}
		}
		.storeButton(.visible, for: .redeemCode)
		.storeButton(.visible, for: .restorePurchases)
		.subscriptionStoreControlStyle(.compactPicker)
	}

	private var lifetimeSection: some View {
		VStack(spacing: 12) {
			HStack {
				Rectangle()
					.frame(height: 1)
					.foregroundStyle(.separator)
				Text("premium_or_buy_once")
					.font(.caption)
					.foregroundStyle(.secondary)
					.layoutPriority(1)
				Rectangle()
					.frame(height: 1)
					.foregroundStyle(.separator)
			}

			Button {
				isPurchasing = true
				Task {
					do {
						_ = try await premiumManager.purchase(.lifetime)
						dismissAfterPurchase()
					} catch {
						purchaseError = error.localizedDescription
					}
					isPurchasing = false
				}
			} label: {
				HStack {
					VStack(alignment: .leading, spacing: 2) {
						Text("premium_lifetime_title")
							.font(.subheadline.bold())
						Text("premium_lifetime_desc")
							.font(.caption)
							.foregroundStyle(.secondary)
					}
					Spacer()
					if let price = premiumManager.lifetimeDisplayPrice {
						Text(price)
							.font(.subheadline.bold())
					}
				}
				.padding(12)
				.background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
			}
			.buttonStyle(.plain)
			.disabled(isPurchasing)
		}
		.padding(.horizontal, 20)
		.padding(.bottom, 20)
	}

	private func dismissAfterPurchase() {
		if premiumManager.isPremium {
			dismiss()
		}
	}

	private func featureRow(_ icon: String, _ text: LocalizedStringKey) -> some View {
		HStack(spacing: 8) {
			Image(systemName: icon)
				.frame(width: 20)
				.foregroundStyle(.yellow)
			Text(text)
				.font(.subheadline)
		}
	}
}
