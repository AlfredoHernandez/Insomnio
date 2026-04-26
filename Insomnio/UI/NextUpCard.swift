//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Insomniac
import Schedule
import SwiftUI

/// Dashboard card showing what's coming next: active auto-stop countdown,
/// current session start, or upcoming scheduled window.
struct NextUpCard: View {
	@Bindable var insomniac: Insomniac
	let scheduleRulesCount: Int
	let onManageSchedule: () -> Void

	var body: some View {
		CardView {
			VStack(alignment: .leading, spacing: 10) {
				liquidGlassSectionTitle("next_up_title", systemImage: "clock.badge")
				content
			}
		}
	}

	@ViewBuilder
	private var content: some View {
		if insomniac.isActive, insomniac.autoStopIsRunning {
			row(
				icon: "timer",
				title: "next_up_autostop_title",
				value: Text("next_up_autostop_value \(insomniac.autoStopRemainingTime.formattedCountdown)"),
			)
		} else if insomniac.isActive {
			row(
				icon: "bolt.fill",
				title: "next_up_active_title",
				value: Text("next_up_active_value"),
			)
		} else if scheduleRulesCount > 0 {
			row(
				icon: "calendar",
				title: "next_up_schedule_title",
				value: Text("next_up_schedule_value \(scheduleRulesCount)"),
				cta: ("next_up_manage", onManageSchedule),
			)
		} else {
			row(
				icon: "calendar.badge.plus",
				title: "next_up_idle_title",
				value: Text("next_up_idle_value"),
				cta: ("hero_add_schedule", onManageSchedule),
			)
		}
	}

	private func row(
		icon: String,
		title: LocalizedStringKey,
		value: Text,
		cta: (LocalizedStringKey, () -> Void)? = nil,
	) -> some View {
		HStack(spacing: 12) {
			Image(systemName: icon)
				.font(.system(size: 16, weight: .semibold))
				.foregroundStyle(.secondary)
				.frame(width: 22)

			VStack(alignment: .leading, spacing: 2) {
				Text(title)
					.font(LiquidGlassStyle.metricLabelFont)
					.foregroundStyle(.secondary)
				value
					.font(.system(size: 14, weight: .medium, design: .rounded))
					.monospacedDigit()
					.foregroundStyle(.primary)
			}

			Spacer()

			if let cta {
				Button(action: cta.1) {
					Text(cta.0)
						.font(.system(size: 12, weight: .medium))
				}
				.liquidGlassPrimaryButton()
				.controlSize(.small)
			}
		}
	}
}

#if DEBUG
#Preview {
	NextUpCard(
		insomniac: Insomniac(
			mouseMover: MouseMoverPreviewStub(),
			sleepPreventer: SleepPreventerPreviewStub(),
			timerScheduler: TimerSchedulerPreviewStub(),
		),
		scheduleRulesCount: 0,
		onManageSchedule: {},
	)
	.padding()
	.frame(width: 640)
}
#endif
