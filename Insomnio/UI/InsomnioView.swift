//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct InsomnioView: View {
	@Bindable var insomniac: Insomniac
	let premiumManager: any PremiumManager
	let scheduleEvaluator: any ScheduleEvaluator
	let appRulesEvaluator: any AppRulesEvaluator
	let launchAtLoginManager: any LaunchAtLoginManager
	let availableApps: () -> [AppPickerView.AppInfo]
	@State private var showingPaywall = false
	@State private var isPremium = false

	private var appVersion: String {
		Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
	}

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 12) {
				StatusSection(isActive: insomniac.isActive, onToggle: {
					insomniac.toggle()
				})

				ModeSection(mode: $insomniac.mode, isDisabled: insomniac.isActive)

				if insomniac.mode == .moveCursor {
					IntervalSection(interval: $insomniac.interval, isDisabled: insomniac.isActive)

					CursorPatternSection(
						cursorPattern: $insomniac.cursorPattern,
						isDisabled: insomniac.isActive,
					)
					.premiumGated(isPremium: isPremium) {
						showingPaywall = true
					}
				}

				OptionsSection(
					onlyWhenIdle: $insomniac.onlyWhenIdle,
					pauseOnBattery: $insomniac.pauseOnBattery,
					isPreventSleepMode: insomniac.mode == .preventSleep,
					launchAtLoginManager: launchAtLoginManager,
				)

				AutoStopSection(
					autoStopEnabled: $insomniac.autoStopEnabled,
					autoStopDuration: $insomniac.autoStopDuration,
					isRunning: insomniac.autoStopIsRunning,
					remainingTime: insomniac.autoStopRemainingTime,
				)
				.premiumGated(isPremium: isPremium) {
					showingPaywall = true
				}

				ScheduleSection(scheduleEvaluator: scheduleEvaluator)
					.premiumGated(isPremium: isPremium) {
						showingPaywall = true
					}

				AppRulesSection(appRulesEvaluator: appRulesEvaluator, availableApps: availableApps)
					.premiumGated(isPremium: isPremium) {
						showingPaywall = true
					}

				if insomniac.activationCount > 0 {
					FeedbackSection(
						activationCount: insomniac.activationCount,
						lastActivation: insomniac.lastActivation,
					)
				}

				PremiumSection(isPremium: isPremium) {
					showingPaywall = true
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
		.frame(width: 420)
		.fixedSize(horizontal: true, vertical: false)
		.animation(.default, value: insomniac.mode)
		.animation(.default, value: insomniac.autoStopEnabled)
		.onAppear { isPremium = premiumManager.isPremium }
		.sheet(isPresented: $showingPaywall, onDismiss: { isPremium = premiumManager.isPremium }) {
			PaywallView(premiumManager: premiumManager)
		}
	}
}

#Preview {
	InsomnioView(
		insomniac: Insomniac(mouseMover: StubMouseMover(), sleepPreventer: StubSleepPreventer(), timerScheduler: StubTimerScheduler()),
		premiumManager: StubPremiumManager(),
		scheduleEvaluator: StubScheduleEvaluator(),
		appRulesEvaluator: StubAppRulesEvaluator(),
		launchAtLoginManager: StubLaunchAtLoginManager(),
		availableApps: { [] },
	)
}
