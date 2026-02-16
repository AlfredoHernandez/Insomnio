//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

@main
struct InsomnioApp: App {
	@State private var coordinator = AppCoordinator(dependencies: .create())

	var body: some Scene {
		Window("Insomnio", id: "main") {
			coordinator.makeMainView()
				.onAppear {
					coordinator.start()
				}
		}
		.defaultSize(width: 420, height: 560)
		.windowResizability(.contentSize)
	}
}
