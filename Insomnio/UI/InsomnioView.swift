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
	@State private var selection: SettingsDestination? = .dashboard

	var body: some View {
		NavigationSplitView {
			SettingsSidebar(selection: $selection)
		} detail: {
			VStack(alignment: .leading, spacing: 12) {
				AccessibilityPermissionBanner(checker: accessibilityPermissionChecker)

				switch selection ?? .dashboard {
				case .dashboard:
					DashboardSettingsView(
						insomniac: insomniac,
						premiumManager: premiumManager,
						scheduleEvaluator: scheduleEvaluator,
						appRulesEvaluator: appRulesEvaluator,
						selection: $selection,
						showingPaywall: $showingPaywall,
					)

				case .status:
					StatusSettingsView(insomniac: insomniac)

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
			.padding(.top, 12)
		}
		.frame(minWidth: 840, minHeight: 560)
		.task {
			await premiumManager.refreshStatus()
		}
		.sheet(isPresented: $showingPaywall) {
			PaywallView(premiumManager: premiumManager)
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
