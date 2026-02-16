//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import ServiceManagement
import SwiftUI

struct SettingsSection: View {
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Toggle("launch_at_login_label", isOn: Binding(
				get: { SMAppService.mainApp.status == .enabled },
				set: { newValue in
					try? newValue
						? SMAppService.mainApp.register()
						: SMAppService.mainApp.unregister()
				},
			))
		}
	}
}
