//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Insomniac
import SwiftUI

/// Primary dashboard hero showing activation state, source and live timer.
///
/// Uses Liquid Glass with a state-tinted background so the current status is
/// immediately legible at a glance.
struct HeroCard: View {
	@Bindable var insomniac: Insomniac

	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			header
			if insomniac.autoStopIsRunning {
				countdownRow
			}
			if insomniac.activationCount > 0 {
				footerStats
			}
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding(20)
		.background {
			RoundedRectangle(cornerRadius: LiquidGlassStyle.cornerRadius, style: .continuous)
				.fill(tintColor.opacity(insomniac.isActive ? 0.18 : 0.0))
		}
		.glassEffect(.regular, in: RoundedRectangle(cornerRadius: LiquidGlassStyle.cornerRadius, style: .continuous))
		.overlay {
			RoundedRectangle(cornerRadius: LiquidGlassStyle.cornerRadius, style: .continuous)
				.strokeBorder(.white.opacity(LiquidGlassStyle.cardStrokeOpacity), lineWidth: LiquidGlassStyle.cardStrokeWidth)
		}
		.animation(.easeInOut(duration: 0.2), value: insomniac.isActive)
	}

	private var header: some View {
		HStack(alignment: .center, spacing: 14) {
			stateIcon

			VStack(alignment: .leading, spacing: 4) {
				Text(insomniac.isActive ? "hero_status_active" : "hero_status_idle")
					.font(.system(size: 28, weight: .semibold, design: .rounded))
					.foregroundStyle(.primary)

				Text(subtitleKey)
					.font(.system(size: 12))
					.foregroundStyle(.secondary)
			}

			Spacer()

			if insomniac.isActive, let source = insomniac.activationSource {
				ActivationSourcePill(source: source)
			}

			Toggle("enable_label", isOn: Binding(
				get: { insomniac.isActive },
				set: { _ in insomniac.toggle(from: .mainWindow) },
			))
			.toggleStyle(.switch)
			.tint(.green)
			.controlSize(.large)
			.labelsHidden()
		}
	}

	private var stateIcon: some View {
		ZStack {
			Circle()
				.fill(tintColor.opacity(insomniac.isActive ? 0.22 : 0.10))
				.frame(width: 42, height: 42)

			Image(systemName: insomniac.isActive ? "bolt.fill" : "moon.zzz.fill")
				.font(.system(size: 18, weight: .semibold))
				.foregroundStyle(insomniac.isActive ? tintColor : .secondary)
				.symbolRenderingMode(.hierarchical)
		}
	}

	private var countdownRow: some View {
		HStack(spacing: 8) {
			Image(systemName: "timer")
				.font(.system(size: 13, weight: .medium))
				.foregroundStyle(.secondary)

			Text("hero_autostop_remaining \(insomniac.autoStopRemainingTime.formattedCountdown)")
				.font(.system(size: 14, weight: .medium, design: .rounded))
				.monospacedDigit()
				.foregroundStyle(.primary)
		}
		.padding(.horizontal, 10)
		.padding(.vertical, 6)
		.glassEffect(.regular, in: Capsule())
	}

	private var footerStats: some View {
		HStack(spacing: 6) {
			Text("feedback_count \(insomniac.activationCount)")
				.monospacedDigit()

			if let lastActivation = insomniac.lastActivation {
				Text("·")
				Text("feedback_last \(lastActivation.formatted(date: .omitted, time: .standard))")
					.monospacedDigit()
			}
		}
		.font(.system(size: 11))
		.foregroundStyle(.secondary)
	}

	private var subtitleKey: LocalizedStringKey {
		insomniac.isActive ? "hero_subtitle_active" : "hero_subtitle_idle"
	}

	private var tintColor: Color {
		insomniac.isActive ? .green : .secondary
	}
}

#Preview("Active") {
	let insomniac = Insomniac(
		mouseMover: MouseMoverPreviewStub(),
		sleepPreventer: SleepPreventerPreviewStub(),
		timerScheduler: TimerSchedulerPreviewStub(),
	)
	insomniac.toggle(from: .mainWindow)
	return HeroCard(insomniac: insomniac)
		.padding()
		.frame(width: 640)
}

#Preview("Idle") {
	HeroCard(insomniac: Insomniac(
		mouseMover: MouseMoverPreviewStub(),
		sleepPreventer: SleepPreventerPreviewStub(),
		timerScheduler: TimerSchedulerPreviewStub(),
	))
	.padding()
	.frame(width: 640)
}
