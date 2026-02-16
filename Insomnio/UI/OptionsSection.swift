//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import ServiceManagement
import SwiftUI

struct OptionsSection: View {
	@Binding var onlyWhenIdle: Bool
	@Binding var pauseOnBattery: Bool
	let isPreventSleepMode: Bool

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
					get: { SMAppService.mainApp.status == .enabled },
					set: { newValue in
						try? newValue
							? SMAppService.mainApp.register()
							: SMAppService.mainApp.unregister()
					},
				))
			}
			.toggleStyle(.checkbox)
		}
	}
}
