//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AccessibilityPermission
import AppRules
import AutoUpdate
import Insomniac
import LaunchAtLogin
import Schedule
import SwiftUI

struct InsomnioView: View {
	@Bindable var insomniac: Insomniac
	let scheduleEvaluator: any ScheduleEvaluator
	let appRulesEvaluator: any AppRulesEvaluator
	let launchAtLoginManager: any LaunchAtLoginManager
	let accessibilityPermissionChecker: any AccessibilityPermissionChecker
	let updateController: any UpdateController
	let availableApps: () -> [AppInfo]
	@State private var selection: SettingsDestination = .dashboard

	var body: some View {
		NavigationStack {
			VStack(alignment: .leading, spacing: 12) {
				AccessibilityPermissionBanner(checker: accessibilityPermissionChecker)
				content
			}
			.padding(.top, 12)
			.frame(minWidth: 760, minHeight: 560)
			.toolbar {
				ToolbarItem(placement: .principal) {
					Picker("", selection: $selection) {
						ForEach(SettingsDestination.allCases, id: \.self) { destination in
							Label(destination.title, systemImage: destination.systemImage)
								.tag(destination)
						}
					}
					.pickerStyle(.segmented)
					.labelsHidden()
				}
			}
		}
	}

	@ViewBuilder
	private var content: some View {
		switch selection {
		case .dashboard:
			DashboardSettingsView(
				insomniac: insomniac,
				scheduleEvaluator: scheduleEvaluator,
				appRulesEvaluator: appRulesEvaluator,
				selection: $selection,
			)

		case .keepAwake:
			KeepAwakeSettingsView(insomniac: insomniac)

		case .automation:
			AutomationSettingsView(
				insomniac: insomniac,
				scheduleEvaluator: scheduleEvaluator,
				appRulesEvaluator: appRulesEvaluator,
				availableApps: availableApps,
			)

		case .general:
			GeneralSettingsView(
				insomniac: insomniac,
				launchAtLoginManager: launchAtLoginManager,
				updateController: updateController,
			)
		}
	}
}

#if DEBUG
#Preview {
	InsomnioView(
		insomniac: Insomniac(mouseMover: MouseMoverPreviewStub(), sleepPreventer: SleepPreventerPreviewStub(), timerScheduler: TimerSchedulerPreviewStub()),
		scheduleEvaluator: ScheduleEvaluatorPreviewStub(),
		appRulesEvaluator: AppRulesEvaluatorPreviewStub(),
		launchAtLoginManager: LaunchAtLoginManagerPreviewStub(),
		accessibilityPermissionChecker: AccessibilityPermissionCheckerPreviewStub(),
		updateController: UpdateControllerPreviewStub(),
		availableApps: { [] },
	)
}
#endif
