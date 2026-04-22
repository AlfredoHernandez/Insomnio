//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppKit

enum NSWorkspaceAppInfoProvider {
	static func runningRegularApps() -> [AppInfo] {
		NSWorkspace.shared.runningApplications
			.filter { $0.activationPolicy == .regular }
			.compactMap { app in
				guard let bundleID = app.bundleIdentifier else { return nil }
				let name = app.localizedName ?? bundleID
				let icon = app.icon ?? NSImage(
					systemSymbolName: "app",
					accessibilityDescription: nil,
				) ?? NSImage()
				return AppInfo(bundleID: bundleID, name: name, icon: icon)
			}
	}
}
