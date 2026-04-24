//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppRules
import AutoStop
import Combine
import Insomniac
import Premium
import Schedule
import SwiftUI

struct DashboardSettingsView: View {
	@Bindable var insomniac: Insomniac
	let premiumManager: any PremiumManager
	let scheduleEvaluator: any ScheduleEvaluator
	let appRulesEvaluator: any AppRulesEvaluator
	@Binding var selection: SettingsDestination
	@Binding var showingPaywall: Bool

	@State private var now: Date = .now
	private let ticker = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

	private var modeLabel: LocalizedStringKey {
		insomniac.mode == .moveCursor ? "mode_move_cursor" : "mode_prevent_sleep"
	}

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 16) {
				HeroCard(insomniac: insomniac)

				HStack(alignment: .top, spacing: 16) {
					NextUpCard(
						insomniac: insomniac,
						scheduleRulesCount: scheduleEvaluator.rules.count,
						onManageSchedule: { selection = .automation },
					)
					monitorCard
				}

				RecentActivityCard(
					events: insomniac.recentActivations,
					isActive: insomniac.isActive,
					now: now,
				)

				if !premiumManager.isPremium {
					unlockButton
				}
			}
			.padding(20)
		}
		.onReceive(ticker) { now = $0 }
	}

	private var monitorCard: some View {
		CardView {
			VStack(alignment: .leading, spacing: 12) {
				liquidGlassSectionTitle("settings_dashboard_monitor_title", systemImage: "waveform.path.ecg")

				LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
					MetricTile(
						title: "settings_dashboard_mode",
						value: AnyView(Text(modeLabel)),
					)

					scheduleTile
					appRulesTile
				}
			}
		}
	}

	@ViewBuilder
	private var scheduleTile: some View {
		if !scheduleEvaluator.rules.isEmpty {
			MetricTile(
				title: "schedule_title",
				value: AnyView(Text("\(scheduleEvaluator.rules.count)").monospacedDigit()),
			)
		} else {
			MetricCTATile(
				title: "schedule_title",
				ctaLabel: "hero_add_schedule",
				systemImage: "plus",
			) {
				selection = .automation
			}
		}
	}

	@ViewBuilder
	private var appRulesTile: some View {
		if !appRulesEvaluator.rules.isEmpty {
			MetricTile(
				title: "apprules_title",
				value: AnyView(Text("\(appRulesEvaluator.rules.count)").monospacedDigit()),
			)
		} else {
			MetricCTATile(
				title: "apprules_title",
				ctaLabel: "hero_add_rule",
				systemImage: "plus",
			) {
				selection = .automation
			}
		}
	}

	private var unlockButton: some View {
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

private struct MetricCTATile: View {
	let title: LocalizedStringKey
	let ctaLabel: LocalizedStringKey
	let systemImage: String
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			VStack(alignment: .leading, spacing: 6) {
				Text(title)
					.font(LiquidGlassStyle.metricLabelFont)
					.foregroundStyle(.secondary)

				Label(ctaLabel, systemImage: systemImage)
					.font(.system(size: 13, weight: .medium, design: .rounded))
					.foregroundStyle(.primary)
					.lineLimit(1)
					.minimumScaleFactor(0.75)
			}
			.frame(maxWidth: .infinity, alignment: .leading)
		}
		.buttonStyle(.plain)
		.liquidGlassMetricTile()
		.contentShape(Rectangle())
	}
}

#Preview {
	@Previewable @State var selection: SettingsDestination = .dashboard
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
	.frame(width: 760, height: 640)
}
