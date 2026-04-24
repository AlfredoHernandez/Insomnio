//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

@main
struct InsomnioApp: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

	var body: some Scene {
		Window("Insomnio", id: "main") {
			appDelegate.coordinator.makeMainView()
		}
		.defaultSize(width: 420, height: 560)
		.windowResizability(.contentSize)
	}
}
