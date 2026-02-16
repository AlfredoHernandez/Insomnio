//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct StatusSection: View {
	let isActive: Bool
	let onToggle: () -> Void

	var body: some View {
		CardView {
			HStack {
				VStack(alignment: .leading, spacing: 4) {
					Text("enable_label")
						.font(.headline)

					Text(isActive ? "status_active" : "status_inactive")
						.font(.subheadline)
						.foregroundStyle(.secondary)
				}

				Spacer()

				Toggle("enable_label", isOn: Binding(
					get: { isActive },
					set: { _ in onToggle() },
				))
				.toggleStyle(.switch)
				.tint(.green)
				.labelsHidden()
			}
		}
		.background {
			if isActive {
				RoundedRectangle(cornerRadius: 10, style: .continuous)
					.fill(.green.opacity(0.08))
			}
		}
	}
}
