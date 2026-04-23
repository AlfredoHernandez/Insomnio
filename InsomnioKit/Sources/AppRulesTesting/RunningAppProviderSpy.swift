//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppRules

public final class RunningAppProviderSpy: RunningAppProvider {
	public var stubbedRunningApps: Set<String> = []

	public init() {}

	public func runningAppBundleIdentifiers() -> Set<String> {
		stubbedRunningApps
	}
}
