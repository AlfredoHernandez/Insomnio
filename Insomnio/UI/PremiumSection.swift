//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct PremiumSection: View {
	let isPremium: Bool
	let onUpgrade: () -> Void

	var body: some View {
		if !isPremium {
			Button(action: onUpgrade) {
				CardView {
					HStack {
						VStack(alignment: .leading, spacing: 4) {
							Text("premium_unlock_title")
								.font(.subheadline.bold())

							Text("premium_unlock_desc")
								.font(.system(size: 11))
								.foregroundStyle(.secondary)
						}

						Spacer()

						Image(systemName: "star.circle.fill")
							.font(.title2)
							.foregroundStyle(.yellow)
					}
				}
			}
			.buttonStyle(.plain)
		}
	}
}

#Preview {
	PremiumSection(isPremium: false, onUpgrade: {})
		.padding()
		.frame(width: 420)
}
