//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppRules
import AutoStop
import Insomniac
import Premium
import Schedule
import SwiftUI

struct DashboardSettingsView: View {
	@Bindable var insomniac: Insomniac
	let premiumManager: any PremiumManager
	let scheduleEvaluator: any ScheduleEvaluator
	let appRulesEvaluator: any AppRulesEvaluator
	@Binding var selection: SettingsDestination?
	@Binding var showingPaywall: Bool

	private var modeLabel: LocalizedStringKey {
		insomniac.mode == .moveCursor ? "mode_move_cursor" : "mode_prevent_sleep"
	}

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 12) {
				liquidGlassContainer(spacing: 12) {
					StatusSection(isActive: insomniac.isActive, onToggle: {
						insomniac.toggle(from: .mainWindow)
					})

					monitorCard
					quickActionsCard
				}

				if insomniac.activationCount > 0 {
					FeedbackSection(activationCount: insomniac.activationCount, lastActivation: insomniac.lastActivation)
						.padding(.horizontal, 4)
				}
			}
			.padding(20)
		}
	}

	private var monitorCard: some View {
		CardView {
			VStack(alignment: .leading, spacing: 10) {
				liquidGlassSectionTitle("settings_dashboard_monitor_title", systemImage: "waveform.path.ecg")

				LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
					MetricTile(
						title: "enable_label",
						value: AnyView(Text(insomniac.isActive ? "status_active" : "status_inactive")),
						isEmphasized: insomniac.isActive,
					)

					MetricTile(
						title: "settings_dashboard_mode",
						value: AnyView(Text(modeLabel)),
					)

					MetricTile(
						title: "settings_dashboard_timer",
						value: AnyView(timerValueView),
					)

					MetricTile(
						title: "settings_dashboard_activations",
						value: AnyView(Text("\(insomniac.activationCount)").monospacedDigit()),
					)

					MetricTile(
						title: "schedule_title",
						value: AnyView(Text("\(scheduleEvaluator.rules.count)").monospacedDigit()),
					)

					MetricTile(
						title: "apprules_title",
						value: AnyView(Text("\(appRulesEvaluator.rules.count)").monospacedDigit()),
					)

					if insomniac.isActive, let source = insomniac.activationSource {
						MetricTile(
							title: "settings_dashboard_source",
							value: AnyView(ActivationSourcePill(source: source)),
						)
						.gridCellColumns(2)
					}
				}
			}
		}
	}

	private var timerValueView: some View {
		Group {
			if insomniac.autoStopIsRunning {
				Text(insomniac.autoStopRemainingTime.formattedCountdown)
					.monospacedDigit()
			} else if insomniac.autoStopEnabled {
				Text(autoStopDurationLabel)
			} else {
				Text("settings_dashboard_off")
			}
		}
	}

	private var autoStopDurationLabel: LocalizedStringKey {
		switch insomniac.autoStopDuration {
		case .thirtyMinutes: "autostop_30min"
		case .oneHour: "autostop_1hour"
		case .twoHours: "autostop_2hours"
		case .fourHours: "autostop_4hours"
		}
	}

	private var quickActionsCard: some View {
		CardView {
			VStack(alignment: .leading, spacing: 10) {
				liquidGlassSectionTitle("settings_dashboard_quick_actions_title", systemImage: "bolt.fill")

				HStack(spacing: 10) {
					Button {
						selection = .keepAwake
					} label: {
						Label(SettingsDestination.keepAwake.title, systemImage: SettingsDestination.keepAwake.systemImage)
							.frame(maxWidth: .infinity)
					}
					.liquidGlassPrimaryButton()

					Button {
						selection = .automation
					} label: {
						Label(SettingsDestination.automation.title, systemImage: SettingsDestination.automation.systemImage)
							.frame(maxWidth: .infinity)
					}
					.liquidGlassPrimaryButton()

					Button {
						selection = .general
					} label: {
						Label(SettingsDestination.general.title, systemImage: SettingsDestination.general.systemImage)
							.frame(maxWidth: .infinity)
					}
					.liquidGlassPrimaryButton()
				}
				.controlSize(.regular)

				if !premiumManager.isPremium {
					Button {
						showingPaywall = true
					} label: {
						Label("premium_unlock_title", systemImage: "star.fill")
							.frame(maxWidth: .infinity)
					}
					.liquidGlassPrimaryButton()
					.controlSize(.large)
				}
			}
		}
	}
}

private struct MetricTile: View {
	let title: LocalizedStringKey
	let value: AnyView
	var isEmphasized: Bool = false

	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			Text(title)
				.font(LiquidGlassStyle.metricLabelFont)
				.foregroundStyle(.secondary)

			value
				.font(LiquidGlassStyle.metricValueFont)
				.foregroundStyle(isEmphasized ? .primary : .secondary)
				.lineLimit(1)
				.minimumScaleFactor(0.75)
		}
		.liquidGlassMetricTile()
	}
}

#Preview {
	@Previewable @State var selection: SettingsDestination? = .dashboard
	@Previewable @State var showingPaywall = false
	DashboardSettingsView(
		insomniac: Insomniac(
			mouseMover: MouseMoverPreviewStub(),
			sleepPreventer: SleepPreventerPreviewStub(),
			timerScheduler: TimerSchedulerPreviewStub(),
		),
		premiumManager: PremiumManagerPreviewStub(),
		scheduleEvaluator: ScheduleEvaluatorPreviewStub(),
		appRulesEvaluator: AppRulesEvaluatorPreviewStub(),
		selection: $selection,
		showingPaywall: $showingPaywall,
	)
	.frame(width: 700, height: 520)
}
