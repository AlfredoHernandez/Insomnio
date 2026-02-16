//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct FeedbackSection: View {
	let activationCount: Int
	let lastActivation: Date?

	var body: some View {
		HStack(spacing: 4) {
			Text("feedback_count \(activationCount)")
				.monospacedDigit()

			if let lastActivation {
				Text("·")
				Text("feedback_last \(lastActivation.formatted(date: .omitted, time: .standard))")
					.monospacedDigit()
			}
		}
		.font(.system(size: 11))
		.foregroundStyle(.secondary)
	}
}
