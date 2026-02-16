//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct InsomnioView: View {
	@Bindable var insomniac: Insomniac
	let premiumManager: any PremiumManager
	let scheduleEvaluator: any ScheduleEvaluator
	let appRulesEvaluator: any AppRulesEvaluator
	var onManualToggle: (() -> Void)?
	@State private var showingPaywall = false

	private var appVersion: String {
		Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
	}

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 12) {
				StatusSection(isActive: insomniac.isActive, onToggle: {
					insomniac.toggle()
					onManualToggle?()
				})

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

				OptionsSection(
					onlyWhenIdle: $insomniac.onlyWhenIdle,
					pauseOnBattery: $insomniac.pauseOnBattery,
					isPreventSleepMode: insomniac.mode == .preventSleep,
				)

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

				AppRulesSection(appRulesEvaluator: appRulesEvaluator)
					.premiumGated(isPremium: premiumManager.isPremium) {
						showingPaywall = true
					}

				if insomniac.activationCount > 0 {
					FeedbackSection(
						activationCount: insomniac.activationCount,
						lastActivation: insomniac.lastActivation,
					)
				}

				PremiumSection(isPremium: premiumManager.isPremium) {
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

				#if DEBUG
				if let debugManager = premiumManager as? DebugPremiumManager {
					DebugSection(premiumManager: debugManager)
				}
				#endif
			}
			.padding(20)
		}
		.frame(width: 420)
		.fixedSize(horizontal: true, vertical: false)
		.animation(.default, value: insomniac.mode)
		.animation(.default, value: insomniac.autoStopEnabled)
		.sheet(isPresented: $showingPaywall) {
			PaywallView(premiumManager: premiumManager)
		}
	}
}

#Preview {
	InsomnioView(
		insomniac: Insomniac(mouseMover: CGMouseMover(), sleepPreventer: IOKitSleepPreventer()),
		premiumManager: PreviewPremiumManager(),
		scheduleEvaluator: PreviewScheduleEvaluator(),
		appRulesEvaluator: PreviewAppRulesEvaluator(),
	)
}
