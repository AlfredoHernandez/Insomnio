//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AutoUpdate
import Insomniac
import LaunchAtLogin
import SwiftUI

struct GeneralSettingsView: View {
	@Bindable var insomniac: Insomniac
	let launchAtLoginManager: any LaunchAtLoginManager
	let updateController: any UpdateController

	@State private var automaticallyChecksForUpdates: Bool

	init(
		insomniac: Insomniac,
		launchAtLoginManager: any LaunchAtLoginManager,
		updateController: any UpdateController,
	) {
		self.insomniac = insomniac
		self.launchAtLoginManager = launchAtLoginManager
		self.updateController = updateController
		_automaticallyChecksForUpdates = State(initialValue: updateController.automaticallyChecksForUpdates)
	}

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

				liquidGlassContainer(spacing: 12) {
					updatesSection
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

	private var updatesSection: some View {
		VStack(alignment: .leading, spacing: 8) {
			liquidGlassSectionTitle("settings_updates_title", systemImage: "arrow.down.circle")

			Toggle("settings_updates_automatic", isOn: $automaticallyChecksForUpdates)
				.onChange(of: automaticallyChecksForUpdates) { _, newValue in
					updateController.automaticallyChecksForUpdates = newValue
				}

			Button("settings_updates_check_now") {
				updateController.checkForUpdates()
			}
			.disabled(!updateController.canCheckForUpdates)
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
		updateController: UpdateControllerPreviewStub(),
	)
	.frame(width: 700, height: 520)
}
#endif
