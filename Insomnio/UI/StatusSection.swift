//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct StatusSection: View {
	let isActive: Bool
	let onToggle: () -> Void

	var body: some View {
		VStack(spacing: 12) {
			ZStack {
				Circle()
					.fill(isActive ? Color.green.opacity(0.15) : Color.secondary.opacity(0.08))
					.frame(width: 64, height: 64)

				Image(systemName: isActive ? "moon.zzz.fill" : "moon.zzz")
					.font(.system(size: 26, weight: .medium))
					.foregroundStyle(isActive ? .green : .secondary)
					.contentTransition(.symbolEffect(.replace))
			}

			Text(isActive ? "status_active" : "status_inactive")
				.font(.headline)

			Button(action: onToggle) {
				Text(isActive ? "button_stop" : "button_start")
					.frame(maxWidth: .infinity)
			}
			.controlSize(.large)
			.buttonStyle(.borderedProminent)
			.tint(isActive ? .red : .green)
		}
	}
}
