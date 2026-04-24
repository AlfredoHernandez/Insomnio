//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Insomniac
import SwiftUI

struct StatusSettingsView: View {
	@Bindable var insomniac: Insomniac

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 12) {
				liquidGlassContainer(spacing: 12) {
					StatusSection(isActive: insomniac.isActive, onToggle: {
						insomniac.toggle(from: .mainWindow)
					})
					currentStateCard
				}

				if insomniac.activationCount > 0 {
					FeedbackSection(activationCount: insomniac.activationCount, lastActivation: insomniac.lastActivation)
						.padding(.horizontal, 4)
				}
			}
			.padding(20)
		}
	}

	private var currentStateCard: some View {
		CardView {
			VStack(alignment: .leading, spacing: 8) {
				liquidGlassSectionTitle("status_active", systemImage: "info.circle")

				HStack {
					Text("mode_move_cursor")
						.opacity(insomniac.mode == .moveCursor ? 1 : 0)
					Text("mode_prevent_sleep")
						.opacity(insomniac.mode == .preventSleep ? 1 : 0)
					Spacer()
					Text(insomniac.isActive ? "status_active" : "status_inactive")
						.foregroundStyle(.secondary)
				}
				.font(LiquidGlassStyle.sectionBodyFont)
				.foregroundStyle(LiquidGlassStyle.sectionBodyStyle)

				if insomniac.autoStopIsRunning {
					Text("autostop_remaining \(insomniac.autoStopRemainingTime.formattedCountdown)")
						.font(LiquidGlassStyle.sectionBodyFont)
						.foregroundStyle(LiquidGlassStyle.sectionBodyStyle)
						.monospacedDigit()
				} else if insomniac.autoStopEnabled {
					Text("autostop_title")
						.font(LiquidGlassStyle.sectionBodyFont)
						.foregroundStyle(LiquidGlassStyle.sectionHintStyle)
				}

				if insomniac.isActive, let source = insomniac.activationSource {
					ActivationSourcePill(source: source)
				}
			}
		}
	}
}

#Preview {
	StatusSettingsView(insomniac: Insomniac(
		mouseMover: MouseMoverPreviewStub(),
		sleepPreventer: SleepPreventerPreviewStub(),
		timerScheduler: TimerSchedulerPreviewStub(),
	))
	.frame(width: 700, height: 520)
}
