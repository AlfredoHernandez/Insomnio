//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

@main
struct InsomnioApp: App {
	@State private var autoStopTimer = FoundationAutoStopTimer()
	@State private var premiumManager = StoreKitPremiumManager()
	private let shortcutManager = NSEventGlobalShortcutManager()

	@State private var insomniac: Insomniac

	init() {
		let autoStop = FoundationAutoStopTimer()
		_autoStopTimer = State(initialValue: autoStop)
		_insomniac = State(initialValue: Insomniac(
			mouseMover: CGMouseMover(),
			sleepPreventer: IOKitSleepPreventer(),
			idleTimeProvider: CGIdleTimeProvider(),
			powerSourceProvider: IOKitPowerSourceProvider(),
			autoStopTimer: autoStop,
		))
	}

	var body: some Scene {
		Window("Insomnio", id: "main") {
			InsomnioView(insomniac: insomniac, premiumManager: premiumManager)
				.onAppear {
					shortcutManager.registerShortcut { [insomniac] in
						insomniac.toggle()
					}
					Task {
						await premiumManager.loadProducts()
					}
				}
		}
		.defaultSize(width: 420, height: 560)
		.windowResizability(.contentSize)

		MenuBarExtra("Insomnio", systemImage: insomniac.isActive ? "moon.zzz.fill" : "moon.zzz") {
			MenuBarView(insomniac: insomniac)
		}
	}
}
