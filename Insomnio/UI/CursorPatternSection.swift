//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import CursorPattern
import SwiftUI

extension CursorPattern {
	var label: LocalizedStringKey {
		switch self {
		case .nudge: "pattern_nudge"

		case .circle: "pattern_circle"

		case .zigzag: "pattern_zigzag"

		case .random: "pattern_random"
		}
	}

	var description: LocalizedStringKey {
		switch self {
		case .nudge: "pattern_nudge_desc"

		case .circle: "pattern_circle_desc"

		case .zigzag: "pattern_zigzag_desc"

		case .random: "pattern_random_desc"
		}
	}

	var icon: String {
		switch self {
		case .nudge: "arrow.right.and.line.vertical.and.arrow.left"

		case .circle: "arrow.trianglehead.2.clockwise"

		case .zigzag: "point.bottomleft.forward.to.point.topright.scurvepath"

		case .random: "dice"
		}
	}
}

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
							.background(Color.clear, in: RoundedRectangle(cornerRadius: 6))
							.liquidGlassSelectionBackground(isSelected: cursorPattern == pattern, cornerRadius: 6)
						}
						.buttonStyle(.plain)
					}
				}
			}
			.disabled(isDisabled)
		}
	}
}
