//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct FeedbackSection: View {
	let isActive: Bool
	let activationCount: Int
	let lastActivation: Date?

	var body: some View {
		HStack(spacing: 12) {
			Circle()
				.fill(isActive ? Color.green : Color.secondary.opacity(0.3))
				.frame(width: 8, height: 8)
				.shadow(color: isActive ? .green.opacity(0.6) : .clear, radius: 4)
				.animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isActive)

			VStack(alignment: .leading, spacing: 2) {
				Text("feedback_count \(activationCount)")
					.font(.caption)
					.foregroundStyle(.secondary)
					.contentTransition(.numericText())

				if let lastActivation {
					Text("feedback_last \(lastActivation.formatted(date: .omitted, time: .standard))")
						.font(.caption)
						.foregroundStyle(.tertiary)
				}
			}

			Spacer()
		}
	}
}
