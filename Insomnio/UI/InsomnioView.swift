//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct InsomnioView: View {
	@Bindable var insomniac: Insomniac

	private var appVersion: String {
		Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			StatusSection(isActive: insomniac.isActive, onToggle: insomniac.toggle)

			ModeSection(mode: $insomniac.mode, isDisabled: insomniac.isActive)

			if insomniac.mode == .moveCursor {
				IntervalSection(interval: $insomniac.interval, isDisabled: insomniac.isActive)
			}

			OptionsSection(
				onlyWhenIdle: $insomniac.onlyWhenIdle,
				pauseOnBattery: $insomniac.pauseOnBattery,
				isPreventSleepMode: insomniac.mode == .preventSleep,
			)

			if insomniac.activationCount > 0 {
				FeedbackSection(
					activationCount: insomniac.activationCount,
					lastActivation: insomniac.lastActivation,
				)
			}

			Spacer()

			Text("version_label \(appVersion)")
				.font(.caption)
				.foregroundStyle(.tertiary)
				.frame(maxWidth: .infinity)
		}
		.padding(20)
		.frame(width: 420)
		.fixedSize(horizontal: true, vertical: false)
		.animation(.default, value: insomniac.mode)
	}
}

#Preview {
	InsomnioView(insomniac: Insomniac(mouseMover: CGMouseMover(), sleepPreventer: IOKitSleepPreventer()))
}
