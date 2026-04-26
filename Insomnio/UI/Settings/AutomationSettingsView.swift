//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppRules
import Insomniac
import Schedule
import SwiftUI

struct AutomationSettingsView: View {
	@Bindable var insomniac: Insomniac
	let scheduleEvaluator: any ScheduleEvaluator
	let appRulesEvaluator: any AppRulesEvaluator
	let availableApps: () -> [AppInfo]

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

					ScheduleSection(scheduleEvaluator: scheduleEvaluator)

					AppRulesSection(appRulesEvaluator: appRulesEvaluator, availableApps: availableApps)
				}
			}
			.padding(20)
		}
	}
}

#Preview {
	AutomationSettingsView(
		insomniac: Insomniac(
			mouseMover: MouseMoverPreviewStub(),
			sleepPreventer: SleepPreventerPreviewStub(),
			timerScheduler: TimerSchedulerPreviewStub(),
		),
		scheduleEvaluator: ScheduleEvaluatorPreviewStub(),
		appRulesEvaluator: AppRulesEvaluatorPreviewStub(),
		availableApps: { [] },
	)
	.frame(width: 700, height: 520)
}
