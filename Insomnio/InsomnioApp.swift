//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

@main
struct InsomnioApp: App {
	@State private var insomniac = Insomniac(
		mouseMover: CGMouseMover(),
		sleepPreventer: IOKitSleepPreventer(),
		idleTimeProvider: CGIdleTimeProvider(),
		powerSourceProvider: IOKitPowerSourceProvider(),
	)

	var body: some Scene {
		Window("Insomnio", id: "main") {
			InsomnioView(insomniac: insomniac)
		}
		.defaultSize(width: 420, height: 560)
		.windowResizability(.contentSize)

		MenuBarExtra("Insomnio", systemImage: insomniac.isActive ? "moon.zzz.fill" : "moon.zzz") {
			MenuBarView(insomniac: insomniac)
		}
	}
}
