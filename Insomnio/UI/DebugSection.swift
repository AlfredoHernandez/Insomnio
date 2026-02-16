//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

#if DEBUG

import SwiftUI

struct DebugSection: View {
	@Bindable var premiumManager: DebugPremiumManager

	var body: some View {
		CardView {
			VStack(alignment: .leading, spacing: 8) {
				Label("DEBUG", systemImage: "ladybug")
					.font(.subheadline.bold())
					.foregroundStyle(.orange)

				Toggle("Premium enabled", isOn: $premiumManager.isPremium)
					.toggleStyle(.switch)
					.controlSize(.mini)
			}
		}
		.overlay(
			RoundedRectangle(cornerRadius: 10)
				.stroke(.orange.opacity(0.5), lineWidth: 1),
		)
	}
}

#endif
