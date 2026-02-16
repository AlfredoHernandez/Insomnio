//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct CursorPatternSection: View {
	@Binding var cursorPattern: CursorPattern
	let isDisabled: Bool

	var body: some View {
		CardView {
			VStack(alignment: .leading, spacing: 8) {
				Label("pattern_title", systemImage: "cursorarrow.motionlines")
					.font(.subheadline.bold())

				Text(cursorPattern.description)
					.font(.system(size: 11))
					.foregroundStyle(.secondary)

				LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
					ForEach(CursorPattern.allCases, id: \.self) { pattern in
						Button {
							cursorPattern = pattern
						} label: {
							VStack(spacing: 4) {
								Image(systemName: pattern.icon)
									.font(.title3)
								Text(pattern.label)
									.font(.system(size: 10))
							}
							.frame(maxWidth: .infinity)
							.padding(.vertical, 8)
							.background(
								cursorPattern == pattern
									? Color.accentColor.opacity(0.15)
									: Color.clear,
								in: RoundedRectangle(cornerRadius: 6),
							)
						}
						.buttonStyle(.plain)
					}
				}
			}
			.disabled(isDisabled)
		}
	}
}
