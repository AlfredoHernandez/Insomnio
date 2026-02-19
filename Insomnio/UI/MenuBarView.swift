//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct MenuBarView: View {
	@Bindable var insomniac: Insomniac
	var activateApp: () -> Void = {}
	var quitApp: () -> Void = {}
	@Environment(\.openWindow) private var openWindow

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

			VStack(spacing: 10) {
				HStack {
					Text(insomniac.isActive ? "status_active" : "status_inactive")
						.font(.subheadline.weight(.medium))

					Spacer()

					Text(modeLabel)
						.font(.caption)
						.foregroundStyle(.secondary)
				}

				Button {
					insomniac.toggle()
				} label: {
					Text(insomniac.isActive ? "button_stop" : "button_start")
						.frame(maxWidth: .infinity)
				}
				.controlSize(.large)
				.keyboardShortcut("s")
			}
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
}

#Preview {
	MenuBarView(insomniac: Insomniac(mouseMover: MouseMoverStub(), sleepPreventer: SleepPreventerStub(), timerScheduler: TimerSchedulerStub()))
}
