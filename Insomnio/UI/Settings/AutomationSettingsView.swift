//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppRules
import Insomniac
import Premium
import Schedule
import SwiftUI

struct AutomationSettingsView: View {
	@Bindable var insomniac: Insomniac
	let premiumManager: any PremiumManager
	let scheduleEvaluator: any ScheduleEvaluator
	let appRulesEvaluator: any AppRulesEvaluator
	let availableApps: () -> [AppInfo]
	@Binding var showingPaywall: Bool

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 12) {
				liquidGlassContainer(spacing: 12) {
					AutoStopSection(
						autoStopEnabled: $insomniac.autoStopEnabled,
						autoStopDuration: $insomniac.autoStopDuration,
						isRunning: insomniac.autoStopIsRunning,
						remainingTime: insomniac.autoStopRemainingTime,
					)
					.premiumGated(isPremium: premiumManager.isPremium) {
						showingPaywall = true
					}

					ScheduleSection(scheduleEvaluator: scheduleEvaluator)
						.premiumGated(isPremium: premiumManager.isPremium) {
							showingPaywall = true
						}

					AppRulesSection(appRulesEvaluator: appRulesEvaluator, availableApps: availableApps)
						.premiumGated(isPremium: premiumManager.isPremium) {
							showingPaywall = true
						}
				}
			}
			.padding(20)
		}
	}
}

#Preview {
	@Previewable @State var showingPaywall = false
	AutomationSettingsView(
		insomniac: Insomniac(
			mouseMover: MouseMoverPreviewStub(),
			sleepPreventer: SleepPreventerPreviewStub(),
			timerScheduler: TimerSchedulerPreviewStub(),
		),
		premiumManager: PremiumManagerPreviewStub(),
		scheduleEvaluator: ScheduleEvaluatorPreviewStub(),
		appRulesEvaluator: AppRulesEvaluatorPreviewStub(),
		availableApps: { [] },
		showingPaywall: $showingPaywall,
	)
	.frame(width: 700, height: 520)
}
