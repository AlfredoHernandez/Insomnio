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
				}
			}
			.padding(20)
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
