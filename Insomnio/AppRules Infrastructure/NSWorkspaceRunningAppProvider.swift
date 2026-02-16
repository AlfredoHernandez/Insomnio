//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppKit

final class NSWorkspaceRunningAppProvider: RunningAppProvider {
	func runningAppBundleIdentifiers() -> Set<String> {
		Set(NSWorkspace.shared.runningApplications.compactMap(\.bundleIdentifier))
	}
}
