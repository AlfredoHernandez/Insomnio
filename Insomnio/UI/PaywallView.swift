//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct PaywallView: View {
	let premiumManager: any PremiumManager
	@Environment(\.dismiss) private var dismiss
	@State private var isPurchasing = false

	var body: some View {
		VStack(spacing: 20) {
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

			Button {
				isPurchasing = true
				Task {
					_ = try? await premiumManager.purchase(.lifetime)
					isPurchasing = false
					if premiumManager.isPremium {
						dismiss()
					}
				}
			} label: {
				Text("premium_purchase")
					.frame(maxWidth: .infinity)
			}
			.buttonStyle(.borderedProminent)
			.controlSize(.large)
			.disabled(isPurchasing)

			Button("premium_restore") {
				Task {
					await premiumManager.restorePurchases()
					if premiumManager.isPremium {
						dismiss()
					}
				}
			}
			.buttonStyle(.plain)
			.font(.caption)
			.foregroundStyle(.secondary)
		}
		.padding(30)
		.frame(width: 320)
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
