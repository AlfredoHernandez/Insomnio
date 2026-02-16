//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct InsomnioView: View {
	@Bindable var insomniac: Insomniac

	var body: some View {
		VStack(spacing: 24) {
			StatusSection(isActive: insomniac.isActive, onToggle: insomniac.toggle)

			Divider()

			ModeSection(mode: $insomniac.mode, isDisabled: insomniac.isActive)

			Divider()

			OptionsSection(
				onlyWhenIdle: $insomniac.onlyWhenIdle,
				pauseOnBattery: $insomniac.pauseOnBattery,
				isPreventSleepMode: insomniac.mode == .preventSleep,
			)

			if insomniac.mode == .moveCursor {
				Divider()

				IntervalSection(interval: $insomniac.interval, isDisabled: insomniac.isActive)
			}

			if insomniac.activationCount > 0 {
				Divider()

				FeedbackSection(
					isActive: insomniac.isActive,
					activationCount: insomniac.activationCount,
					lastActivation: insomniac.lastActivation,
				)
			}

			Divider()

			SettingsSection()
		}
		.padding(32)
		.frame(width: 420)
		.fixedSize()
	}
}

#Preview {
	InsomnioView(insomniac: Insomniac(mouseMover: CGMouseMover(), sleepPreventer: IOKitSleepPreventer()))
}
