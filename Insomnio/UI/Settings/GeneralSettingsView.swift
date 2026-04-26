//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Insomniac
import LaunchAtLogin
import SwiftUI

struct GeneralSettingsView: View {
	@Bindable var insomniac: Insomniac
	let launchAtLoginManager: any LaunchAtLoginManager

	private var appVersion: String {
		Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
	}

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 12) {
				liquidGlassContainer(spacing: 12) {
					OptionsSection(
						onlyWhenIdle: $insomniac.onlyWhenIdle,
						pauseOnBattery: $insomniac.pauseOnBattery,
						isPreventSleepMode: insomniac.mode == .preventSleep,
						launchAtLoginManager: launchAtLoginManager,
					)
				}

				HStack {
					Text("version_label \(appVersion)")
						.font(.caption)
						.foregroundStyle(.tertiary)

					Spacer()

					Text("shortcut_hint")
						.font(.caption)
						.foregroundStyle(.tertiary)
				}
			}
			.padding(20)
		}
	}
}

#if DEBUG
#Preview {
	GeneralSettingsView(
		insomniac: Insomniac(
			mouseMover: MouseMoverPreviewStub(),
			sleepPreventer: SleepPreventerPreviewStub(),
			timerScheduler: TimerSchedulerPreviewStub(),
		),
		launchAtLoginManager: LaunchAtLoginManagerPreviewStub(),
	)
	.frame(width: 700, height: 520)
}
#endif
