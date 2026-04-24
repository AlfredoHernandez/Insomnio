//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AccessibilityPermission
import AppRules
import Insomniac
import LaunchAtLogin
import Premium
import Schedule
import SwiftUI

struct InsomnioView: View {
	@Bindable var insomniac: Insomniac
	let premiumManager: any PremiumManager
	let scheduleEvaluator: any ScheduleEvaluator
	let appRulesEvaluator: any AppRulesEvaluator
	let launchAtLoginManager: any LaunchAtLoginManager
	let accessibilityPermissionChecker: any AccessibilityPermissionChecker
	let availableApps: () -> [AppInfo]
	@State private var showingPaywall = false
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
			.task {
				await premiumManager.refreshStatus()
			}
			.sheet(isPresented: $showingPaywall) {
				PaywallView(premiumManager: premiumManager)
			}
		}
	}

	@ViewBuilder
	private var content: some View {
		switch selection {
		case .dashboard:
			DashboardSettingsView(
				insomniac: insomniac,
				premiumManager: premiumManager,
				scheduleEvaluator: scheduleEvaluator,
				appRulesEvaluator: appRulesEvaluator,
				selection: $selection,
				showingPaywall: $showingPaywall,
			)

		case .keepAwake:
			KeepAwakeSettingsView(
				insomniac: insomniac,
				premiumManager: premiumManager,
				showingPaywall: $showingPaywall,
			)

		case .automation:
			AutomationSettingsView(
				insomniac: insomniac,
				premiumManager: premiumManager,
				scheduleEvaluator: scheduleEvaluator,
				appRulesEvaluator: appRulesEvaluator,
				availableApps: availableApps,
				showingPaywall: $showingPaywall,
			)

		case .general:
			GeneralSettingsView(
				insomniac: insomniac,
				premiumManager: premiumManager,
				launchAtLoginManager: launchAtLoginManager,
				showingPaywall: $showingPaywall,
			)
		}
	}
}

#Preview {
	InsomnioView(
		insomniac: Insomniac(mouseMover: MouseMoverPreviewStub(), sleepPreventer: SleepPreventerPreviewStub(), timerScheduler: TimerSchedulerPreviewStub()),
		premiumManager: PremiumManagerPreviewStub(),
		scheduleEvaluator: ScheduleEvaluatorPreviewStub(),
		appRulesEvaluator: AppRulesEvaluatorPreviewStub(),
		launchAtLoginManager: LaunchAtLoginManagerPreviewStub(),
		accessibilityPermissionChecker: AccessibilityPermissionCheckerPreviewStub(),
		availableApps: { [] },
	)
}
