//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import ServiceManagement

final class SMAppServiceLaunchAtLoginManager: LaunchAtLoginManager {
	var isEnabled: Bool {
		SMAppService.mainApp.status == .enabled
	}

	func enable() throws {
		try SMAppService.mainApp.register()
	}

	func disable() throws {
		try SMAppService.mainApp.unregister()
	}
}
