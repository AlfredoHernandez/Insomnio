//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct OptionsSection: View {
	@Binding var onlyWhenIdle: Bool
	@Binding var pauseOnBattery: Bool
	let isPreventSleepMode: Bool

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("options_label")
				.font(.subheadline)
				.foregroundStyle(.secondary)

			Toggle("only_when_idle_label", isOn: $onlyWhenIdle)
				.disabled(isPreventSleepMode)
				.opacity(isPreventSleepMode ? 0.4 : 1)

			Toggle("pause_on_battery_label", isOn: $pauseOnBattery)
		}
	}
}
