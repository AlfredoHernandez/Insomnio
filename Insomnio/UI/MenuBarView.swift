//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct MenuBarView: View {
	@Bindable var insomniac: Insomniac
	@Environment(\.openWindow) private var openWindow
	var onManualToggle: (() -> Void)?

	private var modeLabel: LocalizedStringKey {
		insomniac.mode == .moveCursor ? "mode_move_cursor" : "mode_prevent_sleep"
	}

	var body: some View {
		Text(insomniac.isActive ? "status_active" : "status_inactive")
		Text(modeLabel)
			.foregroundStyle(.secondary)

		Divider()

		Button(insomniac.isActive ? "button_stop" : "button_start") {
			insomniac.toggle()
			onManualToggle?()
		}
		.keyboardShortcut("s")

		Divider()

		Button("menu_open_insomnio") {
			openWindow(id: "main")
			NSApplication.shared.activate(ignoringOtherApps: true)
		}
		.keyboardShortcut(",")

		Divider()

		Button("quit_button") {
			NSApplication.shared.terminate(nil)
		}
		.keyboardShortcut("q")
	}
}

#Preview {
	MenuBarView(insomniac: Insomniac(mouseMover: CGMouseMover(), sleepPreventer: IOKitSleepPreventer()))
}
