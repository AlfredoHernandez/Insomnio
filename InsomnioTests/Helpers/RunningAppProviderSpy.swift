//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import AppRules

@MainActor
final class RunningAppProviderSpy: RunningAppProvider {
	var stubbedRunningApps: Set<String> = []

	func runningAppBundleIdentifiers() -> Set<String> {
		stubbedRunningApps
	}
}
