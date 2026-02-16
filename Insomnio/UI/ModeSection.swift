//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct ModeSection: View {
	@Binding var mode: Insomniac.Mode
	let isDisabled: Bool

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("mode_label")
				.font(.subheadline)
				.foregroundStyle(.secondary)

			Picker("mode_label", selection: $mode) {
				Text("mode_move_cursor").tag(Insomniac.Mode.moveCursor)
				Text("mode_prevent_sleep").tag(Insomniac.Mode.preventSleep)
			}
			.pickerStyle(.segmented)
			.labelsHidden()
			.disabled(isDisabled)
		}
	}
}
