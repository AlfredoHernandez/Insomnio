//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Insomniac
import SwiftUI

/// Compact “source” chip for the menu bar popover; uses Liquid Glass on macOS 26+.
struct ActivationSourcePill: View {
	let source: Insomniac.ActivationSource

	var body: some View {
		Label {
			Text(titleKey)
		} icon: {
			Image(systemName: source.systemSymbolName)
		}
		.font(.caption.weight(.medium))
		.labelStyle(.titleAndIcon)
		.foregroundStyle(.primary)
		.padding(.horizontal, 10)
		.padding(.vertical, 5)
		.accessibilityLabel(Text(titleKey))
		.modifier(LiquidGlassCapsuleStyle())
	}

	private var titleKey: LocalizedStringKey {
		switch source {
		case .menuBar: "activation_source_pill_menu_bar"
		case .mainWindow: "activation_source_pill_main_window"
		case .globalShortcut: "activation_source_pill_keyboard_shortcut"
		case .shortcutsIntent: "activation_source_pill_shortcuts"
		case .automation: "activation_source_pill_automation"
		}
	}
}

// MARK: - Liquid Glass

private struct LiquidGlassCapsuleStyle: ViewModifier {
	func body(content: Content) -> some View {
		if #available(macOS 26.0, *) {
			content.glassEffect(.regular, in: Capsule())
		} else {
			content
				.background {
					Capsule()
						.fill(.ultraThinMaterial)
				}
				.overlay {
					Capsule()
						.strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
				}
		}
	}
}

// MARK: - Symbols

private extension Insomniac.ActivationSource {
	var systemSymbolName: String {
		switch self {
		case .menuBar: "menubar.rectangle"
		case .mainWindow: "macwindow"
		case .globalShortcut: "keyboard"
		case .shortcutsIntent: "command.square.fill"
		case .automation: "gearshape.2.fill"
		}
	}
}
