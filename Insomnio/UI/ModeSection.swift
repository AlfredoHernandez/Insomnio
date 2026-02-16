//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct ModeSection: View {
	@Binding var mode: Insomniac.Mode
	let isDisabled: Bool

	private var modeDescription: LocalizedStringKey {
		switch mode {
		case .moveCursor:
			"mode_move_cursor_desc"

		case .preventSleep:
			"mode_prevent_sleep_desc"
		}
	}

	var body: some View {
		CardView {
			VStack(alignment: .leading, spacing: 8) {
				Picker(selection: $mode) {
					Text("mode_move_cursor").tag(Insomniac.Mode.moveCursor)
					Text("mode_prevent_sleep").tag(Insomniac.Mode.preventSleep)
				} label: {
					EmptyView()
				}
				.pickerStyle(.segmented)
				.disabled(isDisabled)

				Text(modeDescription)
					.font(.system(size: 11))
					.foregroundStyle(.secondary)
					.fixedSize(horizontal: false, vertical: true)
			}
		}
	}
}
