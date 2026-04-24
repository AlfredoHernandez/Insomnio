//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Insomniac
import Premium
import SwiftUI

struct KeepAwakeSettingsView: View {
	@Bindable var insomniac: Insomniac
	let premiumManager: any PremiumManager
	@Binding var showingPaywall: Bool

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
						.premiumGated(isPremium: premiumManager.isPremium) {
							showingPaywall = true
						}
					}
				}
			}
			.padding(20)
		}
		.animation(.default, value: insomniac.mode)
	}
}

#Preview {
	@Previewable @State var showingPaywall = false
	KeepAwakeSettingsView(
		insomniac: Insomniac(
			mouseMover: MouseMoverPreviewStub(),
			sleepPreventer: SleepPreventerPreviewStub(),
			timerScheduler: TimerSchedulerPreviewStub(),
		),
		premiumManager: PremiumManagerPreviewStub(),
		showingPaywall: $showingPaywall,
	)
	.frame(width: 700, height: 520)
}
