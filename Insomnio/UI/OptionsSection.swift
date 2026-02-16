//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct OptionsSection: View {
	@Binding var onlyWhenIdle: Bool
	@Binding var pauseOnBattery: Bool
	let isPreventSleepMode: Bool
	let launchAtLoginManager: any LaunchAtLoginManager

	var body: some View {
		CardView {
			VStack(alignment: .leading, spacing: 10) {
				VStack(alignment: .leading, spacing: 2) {
					Toggle("only_when_idle_label", isOn: $onlyWhenIdle)
						.disabled(isPreventSleepMode)

					Text("only_when_idle_desc")
						.font(.system(size: 11))
						.foregroundStyle(.tertiary)
						.padding(.leading, 20)
				}

				VStack(alignment: .leading, spacing: 2) {
					Toggle("pause_on_battery_label", isOn: $pauseOnBattery)

					Text("pause_on_battery_desc")
						.font(.system(size: 11))
						.foregroundStyle(.tertiary)
						.padding(.leading, 20)
				}

				Toggle("launch_at_login_label", isOn: Binding(
					get: { launchAtLoginManager.isEnabled },
					set: { newValue in
						try? newValue
							? launchAtLoginManager.enable()
							: launchAtLoginManager.disable()
					},
				))
			}
			.toggleStyle(.checkbox)
		}
	}
}

#if DEBUG
#Preview {
	@Previewable @State var idle = true
	@Previewable @State var battery = false
	OptionsSection(
		onlyWhenIdle: $idle,
		pauseOnBattery: $battery,
		isPreventSleepMode: false,
		launchAtLoginManager: PreviewLaunchAtLoginManager(),
	)
	.padding()
	.frame(width: 420)
}
#endif
