//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

enum LiquidGlassStyle {
	static let cornerRadius: CGFloat = 14
	static let cardPadding: CGFloat = 14
	// Keep strokes very subtle to stay “pro” (A) while still showing glass depth (B).
	static let cardStrokeOpacity: Double = 0.08
	static let cardStrokeWidth: CGFloat = 0.5
	static let iconButtonSize: CGFloat = 26
}

extension View {
	func liquidGlassCard() -> some View {
		frame(maxWidth: .infinity, alignment: .leading)
			.padding(LiquidGlassStyle.cardPadding)
			.glassEffect(.regular, in: RoundedRectangle(cornerRadius: LiquidGlassStyle.cornerRadius, style: .continuous))
			.overlay {
				RoundedRectangle(cornerRadius: LiquidGlassStyle.cornerRadius, style: .continuous)
					.strokeBorder(.white.opacity(LiquidGlassStyle.cardStrokeOpacity), lineWidth: LiquidGlassStyle.cardStrokeWidth)
			}
	}

	func liquidGlassContainer(spacing: CGFloat, @ViewBuilder content: () -> some View) -> some View {
		GlassEffectContainer(spacing: spacing) {
			content()
		}
	}

	func liquidGlassPrimaryButton() -> some View {
		buttonStyle(.glass)
	}

	func liquidGlassIconButton() -> some View {
		buttonStyle(.glass)
			.controlSize(.mini)
			.frame(width: LiquidGlassStyle.iconButtonSize, height: LiquidGlassStyle.iconButtonSize)
	}

	@ViewBuilder
	func liquidGlassSelectionBackground(isSelected: Bool, cornerRadius: CGFloat = 8) -> some View {
		if isSelected {
			glassEffect(.regular, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
				.overlay {
					RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
						.strokeBorder(.white.opacity(0.14), lineWidth: 0.5)
				}
		} else {
			self
		}
	}
}
