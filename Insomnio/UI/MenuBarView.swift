//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct MenuBarView: View {
	@Bindable var insomniac: Insomniac
	@Environment(\.openWindow) private var openWindow

	var body: some View {
		Text(insomniac.isActive ? "status_active" : "status_inactive")

		Divider()

		Button(insomniac.isActive ? "button_stop" : "button_start") {
			insomniac.toggle()
		}

		Divider()

		Button("menu_open_insomnio") {
			openWindow(id: "main")
			NSApplication.shared.activate(ignoringOtherApps: true)
		}

		Divider()

		Button("quit_button") {
			NSApplication.shared.terminate(nil)
		}
	}
}
