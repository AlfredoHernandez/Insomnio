//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppKit

public final class NSWorkspaceRunningAppProvider: RunningAppProvider {
	public init() {}

	public func runningAppBundleIdentifiers() -> Set<String> {
		Set(NSWorkspace.shared.runningApplications.compactMap(\.bundleIdentifier))
	}
}
