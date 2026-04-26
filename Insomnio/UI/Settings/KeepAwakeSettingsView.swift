//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Insomniac
import SwiftUI

struct KeepAwakeSettingsView: View {
	@Bindable var insomniac: Insomniac

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 12) {
				liquidGlassContainer(spacing: 12) {
					ModeSection(mode: $insomniac.mode, isDisabled: insomniac.isActive)

					if insomniac.mode == .moveCursor {
						IntervalSection(interval: $insomniac.interval, isDisabled: insomniac.isActive)

						CursorPatternSection(
							cursorPattern: $insomniac.cursorPattern,
							isDisabled: insomniac.isActive,
						)
					}
				}
			}
			.padding(20)
		}
		.animation(.default, value: insomniac.mode)
	}
}

#Preview {
	KeepAwakeSettingsView(
		insomniac: Insomniac(
			mouseMover: MouseMoverPreviewStub(),
			sleepPreventer: SleepPreventerPreviewStub(),
			timerScheduler: TimerSchedulerPreviewStub(),
		),
	)
	.frame(width: 700, height: 520)
}
