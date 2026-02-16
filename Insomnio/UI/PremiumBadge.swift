//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct PremiumBadge: ViewModifier {
	let isPremium: Bool
	let onTap: () -> Void

	func body(content: Content) -> some View {
		if isPremium {
			content
		} else {
			content
				.overlay {
					RoundedRectangle(cornerRadius: 10, style: .continuous)
						.fill(.ultraThinMaterial.opacity(0.8))
						.overlay {
							VStack(spacing: 4) {
								Image(systemName: "lock.fill")
									.font(.title3)
								Text("premium_feature_locked")
									.font(.system(size: 11))
							}
							.foregroundStyle(.secondary)
						}
				}
				.onTapGesture(perform: onTap)
		}
	}
}

extension View {
	func premiumGated(isPremium: Bool, onTap: @escaping () -> Void) -> some View {
		modifier(PremiumBadge(isPremium: isPremium, onTap: onTap))
	}
}

#Preview("Locked") {
	CardView {
		VStack(alignment: .leading, spacing: 8) {
			Toggle("Auto-stop", isOn: .constant(false))
			Text("Stops after a set time")
				.font(.system(size: 11))
				.foregroundStyle(.tertiary)
		}
	}
	.premiumGated(isPremium: false, onTap: {})
	.padding()
	.frame(width: 420)
}

#Preview("Unlocked") {
	CardView {
		VStack(alignment: .leading, spacing: 8) {
			Toggle("Auto-stop", isOn: .constant(true))
			Text("Stops after a set time")
				.font(.system(size: 11))
				.foregroundStyle(.tertiary)
		}
	}
	.premiumGated(isPremium: true, onTap: {})
	.padding()
	.frame(width: 420)
}
