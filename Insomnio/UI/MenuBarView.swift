//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Insomniac
import SwiftUI

struct MenuBarView: View {
	@Bindable var insomniac: Insomniac
	var activateApp: () -> Void = {}
	var quitApp: () -> Void = {}
	@Environment(\.openWindow) private var openWindow
	@Namespace private var glassNamespace

	private var modeLabel: LocalizedStringKey {
		insomniac.mode == .moveCursor ? "mode_move_cursor" : "mode_prevent_sleep"
	}

	var body: some View {
		VStack(spacing: 0) {
			HStack {
				Label("Insomnio", systemImage: insomniac.isActive ? "moon.zzz.fill" : "moon.zzz")
					.font(.headline)

				Spacer()

				Circle()
					.fill(insomniac.isActive ? .green : .secondary.opacity(0.5))
					.frame(width: 8, height: 8)
			}
			.padding(.horizontal, 16)
			.padding(.vertical, 12)

			Divider()

			contentBody
				.padding(.horizontal, 16)
				.padding(.vertical, 12)

			Divider()

			HStack {
				Button("menu_open_insomnio") {
					openWindow(id: "main")
					activateApp()
				}
				.buttonStyle(.plain)
				.foregroundStyle(.secondary)
				.font(.caption)
				.keyboardShortcut(",")

				Spacer()

				Button("quit_button") {
					quitApp()
				}
				.buttonStyle(.plain)
				.foregroundStyle(.secondary)
				.font(.caption)
				.keyboardShortcut("q")
			}
			.padding(.horizontal, 16)
			.padding(.vertical, 10)
		}
		.frame(width: 260)
	}

	private var contentBody: some View {
		GlassEffectContainer(spacing: 10) {
			innerContentBody
		}
	}

	private var innerContentBody: some View {
		VStack(spacing: 10) {
			HStack {
				Text(insomniac.isActive ? "status_active" : "status_inactive")
					.font(.subheadline.weight(.medium))

				Spacer()

				Text(modeLabel)
					.font(.caption)
					.foregroundStyle(.secondary)
			}

			if insomniac.autoStopIsRunning {
				Text("autostop_remaining \(insomniac.autoStopRemainingTime.formattedCountdown)")
					.font(.caption)
					.foregroundStyle(.secondary)
					.monospacedDigit()
					.frame(maxWidth: .infinity, alignment: .leading)
			}

			if insomniac.isActive, let source = insomniac.activationSource {
				ActivationSourcePill(source: source)
					.frame(maxWidth: .infinity, alignment: .leading)
					.liquidGlassID("activationSourcePill", in: glassNamespace)
			}

			Button {
				insomniac.toggle(from: .menuBar)
			} label: {
				Text(insomniac.isActive ? "button_stop" : "button_start")
					.frame(maxWidth: .infinity)
			}
			.controlSize(.large)
			.keyboardShortcut("s")
			.liquidGlassPrimaryButton()
			.liquidGlassID("primaryAction", in: glassNamespace)
		}
	}
}

#if DEBUG
#Preview {
	MenuBarView(insomniac: Insomniac(
		mouseMover: MouseMoverPreviewStub(),
		sleepPreventer: SleepPreventerPreviewStub(),
		timerScheduler: TimerSchedulerPreviewStub(),
	))
}
#endif

private extension View {
	func liquidGlassID<ID: Hashable & Sendable>(_ id: ID, in namespace: Namespace.ID) -> some View {
		glassEffectID(id, in: namespace)
	}
}
