//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import ServiceManagement

public final class SMAppServiceLaunchAtLoginManager: LaunchAtLoginManager {
	public init() {}

	public var isEnabled: Bool {
		SMAppService.mainApp.status == .enabled
	}

	public func enable() throws {
		try SMAppService.mainApp.register()
	}

	public func disable() throws {
		try SMAppService.mainApp.unregister()
	}
}
