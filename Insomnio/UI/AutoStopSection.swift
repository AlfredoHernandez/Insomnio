//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct AutoStopSection: View {
	@Binding var autoStopEnabled: Bool
	@Binding var autoStopDuration: AutoStopDuration
	let isRunning: Bool
	let remainingTime: TimeInterval

	var body: some View {
		CardView {
			VStack(alignment: .leading, spacing: 8) {
				Toggle("autostop_title", isOn: $autoStopEnabled)
					.toggleStyle(.checkbox)

				Text("autostop_desc")
					.font(.system(size: 11))
					.foregroundStyle(.tertiary)
					.padding(.leading, 20)

				if autoStopEnabled {
					Picker("autostop_duration_label", selection: $autoStopDuration) {
						Text("autostop_30min").tag(AutoStopDuration.thirtyMinutes)
						Text("autostop_1hour").tag(AutoStopDuration.oneHour)
						Text("autostop_2hours").tag(AutoStopDuration.twoHours)
						Text("autostop_4hours").tag(AutoStopDuration.fourHours)
					}
					.pickerStyle(.segmented)
					.labelsHidden()

					if isRunning {
						Text("autostop_remaining \(remainingTime.formattedCountdown)")
							.font(.system(size: 11))
							.foregroundStyle(.secondary)
							.monospacedDigit()
					}
				}
			}
		}
	}
}

#Preview {
	@Previewable @State var enabled = true
	@Previewable @State var duration = AutoStopDuration.oneHour
	AutoStopSection(
		autoStopEnabled: $enabled,
		autoStopDuration: $duration,
		isRunning: true,
		remainingTime: 3542,
	)
	.padding()
	.frame(width: 420)
}
